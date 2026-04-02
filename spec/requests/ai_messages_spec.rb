# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AiMessages", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:user) { create(:user) }
  let(:membership) { create(:membership, :tutorado, user: user, organization: organization) }
  let(:conversation) { create(:ai_conversation, user: user) }

  let(:mock_result) do
    {content: "Let me help you think about this.", input_tokens: 100, output_tokens: 30}
  end

  before do
    membership
    sign_in_as(user)
  end

  describe "POST /ai_conversations/:ai_conversation_id/ai_messages" do
    it "creates a user message and an assistant message" do
      service_double = instance_double(AiTutorService, call: mock_result)
      allow(AiTutorService).to receive(:new).and_return(service_double)

      expect {
        post ai_conversation_ai_messages_path(conversation), params: {ai_message: {content: "How do I solve x^2 = 4?"}}
      }.to change(AiMessage, :count).by(2)

      expect(response).to redirect_to(ai_conversation_path(conversation))

      messages = conversation.ai_messages.order(:id)
      expect(messages.first.role).to eq("user")
      expect(messages.first.content).to eq("How do I solve x^2 = 4?")
      expect(messages.last.role).to eq("assistant")
      expect(messages.last.status).to eq("complete")
      expect(messages.last.content).to eq("Let me help you think about this.")
      expect(messages.last.input_tokens).to eq(100)
      expect(messages.last.output_tokens).to eq(30)
    end

    it "handles API errors by setting status to failed" do
      error_result = {content: "I'm sorry, I encountered an error. Please try again.", input_tokens: nil, output_tokens: nil, error: true}
      service_double = instance_double(AiTutorService, call: error_result)
      allow(AiTutorService).to receive(:new).and_return(service_double)

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
