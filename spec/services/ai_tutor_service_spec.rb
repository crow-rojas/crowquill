# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiTutorService do
  let(:user) { create(:user) }
  let(:conversation) { create(:ai_conversation, user: user) }
  let(:mock_messages_resource) { instance_double(Anthropic::Resources::Messages) }
  let(:mock_client) { instance_double(Anthropic::Client, messages: mock_messages_resource) }

  let(:mock_usage) { double(input_tokens: 150, output_tokens: 50) }
  let(:mock_text_block) { double(text: "Let's think about this step by step.") }
  let(:mock_response) { double(content: [mock_text_block], usage: mock_usage) }

  describe "#call" do
    it "returns content and token counts on success" do
      allow(mock_messages_resource).to receive(:create).and_return(mock_response)

      service = described_class.new(conversation, "How do I solve x^2 = 4?", client: mock_client)
      result = service.call

      expect(result[:content]).to eq("Let's think about this step by step.")
      expect(result[:input_tokens]).to eq(150)
      expect(result[:output_tokens]).to eq(50)
      expect(result[:error]).to be_nil
    end

    it "builds correct message payload with system prompt" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Hello", status: "complete")
      create(:ai_message, :assistant, ai_conversation: conversation, content: "Hi! How can I help?", status: "complete")

      allow(mock_messages_resource).to receive(:create).and_return(mock_response)

      service = described_class.new(conversation, "What is 2+2?", client: mock_client)
      service.call

      expect(mock_messages_resource).to have_received(:create).with(
        hash_including(
          model: "claude-sonnet-4-20250514",
          max_tokens: 2048,
          system: a_string_including("Socratic math tutor"),
          messages: [
            {role: "user", content: "Hello"},
            {role: "assistant", content: "Hi! How can I help?"},
            {role: "user", content: "What is 2+2?"}
          ]
        )
      )
    end

    it "never includes PII in the API payload" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Help me", status: "complete")

      allow(mock_messages_resource).to receive(:create).and_return(mock_response)

      service = described_class.new(conversation, "More help please", client: mock_client)
      service.call

      expect(mock_messages_resource).to have_received(:create) do |args|
        payload_json = args.to_json
        expect(payload_json).not_to include(user.email)
        expect(payload_json).not_to include(user.name)
        expect(payload_json).not_to include("\"user_id\"")

        args[:messages].each do |msg|
          expect(msg.keys).to contain_exactly(:role, :content)
        end
      end
    end

    it "excludes streaming messages from history" do
      create(:ai_message, ai_conversation: conversation, role: "user", content: "First", status: "complete")
      create(:ai_message, :assistant, :streaming, ai_conversation: conversation, content: "")

      allow(mock_messages_resource).to receive(:create).and_return(mock_response)

      service = described_class.new(conversation, "Second", client: mock_client)
      service.call

      expect(mock_messages_resource).to have_received(:create).with(
        hash_including(
          messages: [
            {role: "user", content: "First"},
            {role: "user", content: "Second"}
          ]
        )
      )
    end

    it "includes exercise set content in system prompt when present" do
      exercise_set = create(:exercise_set, content: "Solve $x^2 + 1 = 0$")
      conversation_with_exercise = create(:ai_conversation, user: user, exercise_set: exercise_set)

      allow(mock_messages_resource).to receive(:create).and_return(mock_response)

      service = described_class.new(conversation_with_exercise, "Help me", client: mock_client)
      service.call

      expect(mock_messages_resource).to have_received(:create).with(
        hash_including(
          system: a_string_including("Solve $x^2 + 1 = 0$")
        )
      )
    end

    it "handles API errors gracefully" do
      allow(mock_messages_resource).to receive(:create).and_raise(Anthropic::Errors::APIError.new(url: "https://api.anthropic.com", status: 429, message: "Rate limited"))

      service = described_class.new(conversation, "Help", client: mock_client)
      result = service.call

      expect(result[:error]).to be true
      expect(result[:content]).to include("error")
      expect(result[:input_tokens]).to be_nil
      expect(result[:output_tokens]).to be_nil
    end

    it "handles connection errors gracefully" do
      allow(mock_messages_resource).to receive(:create).and_raise(Anthropic::Errors::APIConnectionError.new(url: "https://api.anthropic.com", message: "Connection refused"))

      service = described_class.new(conversation, "Help", client: mock_client)
      result = service.call

      expect(result[:error]).to be true
      expect(result[:content]).to include("error")
    end
  end
end
