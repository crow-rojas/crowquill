# frozen_string_literal: true

class AiMessage < ApplicationRecord
  ROLES = %w[user assistant].freeze
  STATUSES = %w[streaming complete failed].freeze

  belongs_to :ai_conversation

  validates :role, presence: true, inclusion: {in: ROLES}
  validates :content, presence: true, unless: -> { status == "streaming" }
  validates :status, presence: true, inclusion: {in: STATUSES}

  enum :role, ROLES.index_by(&:itself), validate: true
  enum :status, STATUSES.index_by(&:itself), validate: true, prefix: true
end
