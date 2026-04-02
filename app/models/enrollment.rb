# frozen_string_literal: true

class Enrollment < ApplicationRecord
  STATUSES = %w[active withdrawn].freeze

  belongs_to :section
  belongs_to :user

  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :user_id, uniqueness: {scope: :section_id}

  enum :status, STATUSES.index_by(&:itself), validate: true

  scope :active, -> { where(status: "active") }
end
