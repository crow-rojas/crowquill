# frozen_string_literal: true

class AiConversation < ApplicationRecord
  belongs_to :user
  belongs_to :exercise_set, optional: true
  has_many :ai_messages, dependent: :destroy

  validates :title, presence: true
end
