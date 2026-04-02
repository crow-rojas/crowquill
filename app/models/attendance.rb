# frozen_string_literal: true

class Attendance < ApplicationRecord
  STATUSES = %w[present absent justified].freeze

  belongs_to :tutoring_session
  belongs_to :enrollment

  validates :status, presence: true
  validates :enrollment_id, uniqueness: {scope: :tutoring_session_id}

  enum :status, STATUSES.index_by(&:itself), validate: true
end
