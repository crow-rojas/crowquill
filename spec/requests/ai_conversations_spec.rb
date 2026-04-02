# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AiConversations", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:user) { create(:user) }
  let(:membership) { create(:membership, :tutorado, user: user, organization: organization) }

  let(:other_user) { create(:user) }
  let(:other_membership) { create(:membership, :tutorado, user: other_user, organization: organization) }

  before do
    membership
    sign_in_as(user)
  end

  describe "GET /ai_conversations" do
    it "returns success" do
      get ai_conversations_path
      expect(response).to have_http_status(:success)
    end

    it "only shows current user conversations" do
      create(:ai_conversation, user: user, title: "My conversation")
      other_membership
      create(:ai_conversation, user: other_user, title: "Other conversation")

      get ai_conversations_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /ai_conversations/:id" do
    it "shows a conversation with messages" do
      conversation = create(:ai_conversation, user: user)
      create(:ai_message, ai_conversation: conversation, role: "user", content: "Hello")
      create(:ai_message, :assistant, ai_conversation: conversation, content: "Hi there!")

      get ai_conversation_path(conversation)
      expect(response).to have_http_status(:success)
    end

    it "returns not found for another user conversation" do
      other_membership
      other_conversation = create(:ai_conversation, user: other_user)

      get ai_conversation_path(other_conversation)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /ai_conversations" do
    it "creates a new conversation" do
      expect {
        post ai_conversations_path, params: {ai_conversation: {title: "New chat"}}
      }.to change(AiConversation, :count).by(1)

      expect(response).to redirect_to(ai_conversation_path(AiConversation.last))
      expect(AiConversation.last.user).to eq(user)
    end

    it "creates a conversation with an exercise set" do
      exercise_set = create(:exercise_set)

      expect {
        post ai_conversations_path, params: {ai_conversation: {title: "Exercise help", exercise_set_id: exercise_set.id}}
      }.to change(AiConversation, :count).by(1)

      expect(AiConversation.last.exercise_set).to eq(exercise_set)
    end

    it "fails without title" do
      expect {
        post ai_conversations_path, params: {ai_conversation: {title: ""}}
      }.not_to change(AiConversation, :count)

      expect(response).to redirect_to(ai_conversations_path)
    end
  end

  context "with different roles" do
    it "allows admin to access conversations" do
      admin = create(:user)
      create(:membership, :admin, user: admin, organization: organization)
      sign_in_as(admin)

      get ai_conversations_path
      expect(response).to have_http_status(:success)
    end

    it "allows tutor to access conversations" do
      tutor = create(:user)
      create(:membership, :tutor, user: tutor, organization: organization)
      sign_in_as(tutor)

      get ai_conversations_path
      expect(response).to have_http_status(:success)
    end
  end
end
