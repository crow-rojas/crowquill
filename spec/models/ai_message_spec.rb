# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiMessage do
  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }
    it "validates content presence for non-streaming messages" do
      message = build(:ai_message, content: "", status: "complete")
      expect(message).not_to be_valid
      expect(message.errors[:content]).to be_present
    end

    it "allows empty content for streaming messages" do
      message = build(:ai_message, content: "", status: "streaming")
      expect(message).to be_valid
    end
    it { is_expected.to validate_presence_of(:status) }

    it "validates role inclusion" do
      message = build(:ai_message, role: "invalid")
      expect(message).not_to be_valid
    end

    it "validates status inclusion" do
      message = build(:ai_message, status: "invalid")
      expect(message).not_to be_valid
    end

    it "rejects content longer than 10,000 characters" do
      message = build(:ai_message, content: "a" * 10_001, status: "complete")
      expect(message).not_to be_valid
      expect(message.errors[:content]).to be_present
    end

    it "allows content up to 10,000 characters" do
      message = build(:ai_message, content: "a" * 10_000, status: "complete")
      expect(message).to be_valid
    end

    it "skips content length validation for streaming messages" do
      message = build(:ai_message, content: "", status: "streaming")
      expect(message).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:ai_conversation) }
  end

  describe "enum" do
    it "defines role enum" do
      message = build(:ai_message, role: "user")
      expect(message).to be_user

      message.role = "assistant"
      expect(message).to be_assistant
    end

    it "defines status enum with prefix" do
      message = build(:ai_message, status: "streaming")
      expect(message).to be_status_streaming

      message.status = "complete"
      expect(message).to be_status_complete

      message.status = "failed"
      expect(message).to be_status_failed
    end
  end
end
