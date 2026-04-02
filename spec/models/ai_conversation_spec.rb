# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiConversation do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:exercise_set).optional }
    it { is_expected.to have_many(:ai_messages).dependent(:destroy) }
  end

  describe "creation" do
    it "creates a conversation without an exercise set" do
      conversation = create(:ai_conversation)
      expect(conversation).to be_persisted
      expect(conversation.exercise_set).to be_nil
    end

    it "creates a conversation with an exercise set" do
      conversation = create(:ai_conversation, :with_exercise_set)
      expect(conversation).to be_persisted
      expect(conversation.exercise_set).to be_present
    end
  end
end
