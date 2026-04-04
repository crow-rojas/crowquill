# frozen_string_literal: true

class AcademicPeriod < ApplicationRecord
  STATUSES = %w[draft active archived].freeze

  belongs_to :organization
  has_many :courses, dependent: :destroy

  validates :year, presence: true, numericality: {only_integer: true, greater_than: 2000}
  validates :semester, presence: true, inclusion: {in: [1, 2]}
  validates :year, uniqueness: {scope: %i[organization_id semester]}
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true
  validate :end_date_after_start_date

  enum :status, STATUSES.index_by(&:itself), validate: true

  def canonical_label
    "#{year}-#{semester}"
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end
end
