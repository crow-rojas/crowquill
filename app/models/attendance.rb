# frozen_string_literal: true

class Attendance < ApplicationRecord
  STATUSES = %w[present absent justified].freeze

  belongs_to :tutoring_session
  belongs_to :enrollment

  validates :status, presence: true
  validates :enrollment_id, uniqueness: {scope: :tutoring_session_id}
  validate :enrollment_matches_tutoring_session_section

  enum :status, STATUSES.index_by(&:itself), validate: true

  private

  def enrollment_matches_tutoring_session_section
    return if enrollment.blank? || tutoring_session.blank?
    return if enrollment.section_id == tutoring_session.section_id

    errors.add(:enrollment, :invalid)
  end
end
