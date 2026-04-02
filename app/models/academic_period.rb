# frozen_string_literal: true

class AcademicPeriod < ApplicationRecord
  STATUSES = %w[draft active archived].freeze

  belongs_to :organization
  has_many :courses, dependent: :destroy

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true, inclusion: {in: STATUSES}
  validate :end_date_after_start_date

  enum :status, STATUSES.index_by(&:itself), validate: true

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end
end
