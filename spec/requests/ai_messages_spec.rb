# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AiMessages", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:user) { create(:user) }
  let(:membership) { create(:membership, :tutorado, user: user, organization: organization) }
  let(:conversation) { create(:ai_conversation, user: user) }

  let(:mock_messages_resource) { instance_double(Anthropic::Resources::Messages) }
  let(:mock_client) { instance_double(Anthropic::Client, messages: mock_messages_resource) }

  let(:mock_usage) { double(input_tokens: 100, output_tokens: 30) }
  let(:mock_text_block) { double(text: "Let me help you think about this.") }
  let(:mock_response) { double(content: [mock_text_block], usage: mock_usage) }

  before do
    membership
    sign_in_as(user)
    allow(Anthropic::Client).to receive(:new).and_return(mock_client)
    allow(mock_messages_resource).to receive(:create).and_return(mock_response)
  end

  describe "POST /ai_conversations/:ai_conversation_id/ai_messages" do
    it "creates a user message and an assistant message" do
      expect {
        post ai_conversation_ai_messages_path(conversation), params: {ai_message: {content: "How do I solve x^2 = 4?"}}
      }.to change(AiMessage, :count).by(2)

      expect(response).to redirect_to(ai_conversation_path(conversation))

      messages = conversation.ai_messages.order(:created_at)
      expect(messages.first.role).to eq("user")
      expect(messages.first.content).to eq("How do I solve x^2 = 4?")
      expect(messages.last.role).to eq("assistant")
      expect(messages.last.status).to eq("complete")
      expect(messages.last.content).to eq("Let me help you think about this.")
      expect(messages.last.input_tokens).to eq(100)
      expect(messages.last.output_tokens).to eq(30)
    end

    it "handles API errors by setting status to failed" do
      allow(mock_messages_resource).to receive(:create).and_raise(
        Anthropic::Errors::APIError.new(url: "https://api.anthropic.com", status: 500, message: "API error")
      )

      post ai_conversation_ai_messages_path(conversation), params: {ai_message: {content: "Help"}}

      expect(response).to redirect_to(ai_conversation_path(conversation))

      assistant_message = conversation.ai_messages.where(role: "assistant").last
      expect(assistant_message.status).to eq("failed")
    end

    it "returns not found for another user conversation" do
      other_user = create(:user)
      create(:membership, :tutorado, user: other_user, organization: organization)
      other_conversation = create(:ai_conversation, user: other_user)

      post ai_conversation_ai_messages_path(other_conversation), params: {ai_message: {content: "Sneaky"}}
      expect(response).to have_http_status(:not_found)
    end
  end
end
