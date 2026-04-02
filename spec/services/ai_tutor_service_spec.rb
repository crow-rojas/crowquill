# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiTutorService do
  let(:user) { create(:user) }
  let(:conversation) { create(:ai_conversation, user: user) }

  let(:mock_response) do
    double(
      content: "Let's think about this step by step.",
      input_tokens: 150,
      output_tokens: 50
    )
  end

  let(:mock_chat) do
    instance_double(RubyLLM::Chat).tap do |chat|
      allow(chat).to receive(:with_instructions).and_return(chat)
      allow(chat).to receive(:add_message).and_return(chat)
      allow(chat).to receive(:ask).and_return(mock_response)
    end
  end

  describe "#call" do
    it "returns content and token counts on success" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "How do I solve x^2 = 4?", status: "complete")

      service = described_class.new(conversation, "How do I solve x^2 = 4?", chat: mock_chat)
      result = service.call

      expect(result[:content]).to eq("Let's think about this step by step.")
      expect(result[:input_tokens]).to eq(150)
      expect(result[:output_tokens]).to eq(50)
      expect(result[:error]).to be_nil
    end

    it "sets system prompt and sends user message via ask" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Hello", status: "complete")
      create(:ai_message, :assistant, ai_conversation: conversation, content: "Hi! How can I help?", status: "complete")
      create(:ai_message, ai_conversation: conversation, role: "user", content: "What is 2+2?", status: "complete")

      service = described_class.new(conversation, "What is 2+2?", chat: mock_chat)
      service.call

      expect(mock_chat).to have_received(:with_instructions).with(a_string_including("Socratic math tutor"))
      expect(mock_chat).to have_received(:add_message).with(role: :user, content: "Hello")
      expect(mock_chat).to have_received(:add_message).with(role: :assistant, content: "Hi! How can I help?")
      expect(mock_chat).to have_received(:add_message).twice
      expect(mock_chat).to have_received(:ask).with("What is 2+2?")
    end

    it "never includes PII in the API payload" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Help me", status: "complete")

      service = described_class.new(conversation, "Help me", chat: mock_chat)
      service.call

      expect(mock_chat).to have_received(:with_instructions) do |prompt|
        expect(prompt).not_to include(user.email)
        expect(prompt).not_to include(user.name)
      end

      expect(mock_chat).not_to have_received(:add_message).with(hash_including(content: a_string_including(user.email)))
    end

    it "does not duplicate the user message already saved in the database" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "What is 2+2?", status: "complete")

      service = described_class.new(conversation, "What is 2+2?", chat: mock_chat)
      service.call

      expect(mock_chat).not_to have_received(:add_message)
      expect(mock_chat).to have_received(:ask).with("What is 2+2?")
    end

    it "excludes streaming messages from history" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "First", status: "complete")
      create(:ai_message, :assistant, :streaming, ai_conversation: conversation, content: "")
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Second", status: "complete")

      service = described_class.new(conversation, "Second", chat: mock_chat)
      service.call

      expect(mock_chat).to have_received(:add_message).with(role: :user, content: "First").once
      expect(mock_chat).to have_received(:add_message).once
      expect(mock_chat).to have_received(:ask).with("Second")
    end

    it "includes exercise set content in system prompt when present" do
      exercise_set = create(:exercise_set, content: "Solve $x^2 + 1 = 0$")
      conversation_with_exercise = create(:ai_conversation, user: user, exercise_set: exercise_set)

      create(:ai_message, ai_conversation: conversation_with_exercise, role: "user", content: "Help me", status: "complete")

      service = described_class.new(conversation_with_exercise, "Help me", chat: mock_chat)
      service.call

      expect(mock_chat).to have_received(:with_instructions).with(
        a_string_including("Solve $x^2 + 1 = 0$")
      )
    end

    it "handles API errors gracefully" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Help", status: "complete")
      allow(mock_chat).to receive(:ask).and_raise(RubyLLM::Error.new("Rate limited"))

      service = described_class.new(conversation, "Help", chat: mock_chat)
      result = service.call

      expect(result[:error]).to be true
      expect(result[:content]).to include("error")
      expect(result[:input_tokens]).to be_nil
      expect(result[:output_tokens]).to be_nil
    end

    it "handles connection errors gracefully" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Help", status: "complete")
      allow(mock_chat).to receive(:ask).and_raise(RubyLLM::Error.new("Connection refused"))

      service = described_class.new(conversation, "Help", chat: mock_chat)
      result = service.call

      expect(result[:error]).to be true
      expect(result[:content]).to include("error")
    end
  end
end
