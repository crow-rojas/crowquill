# frozen_string_literal: true

class TutoringSession < ApplicationRecord
  STATUSES = %w[scheduled completed cancelled].freeze

  belongs_to :section
  has_many :attendances, dependent: :destroy

  validates :date, presence: true
  validates :status, presence: true

  enum :status, STATUSES.index_by(&:itself), validate: true

  scope :upcoming, -> { where("date >= ?", Date.current).order(:date) }
end
