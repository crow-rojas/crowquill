# frozen_string_literal: true

class Course < ApplicationRecord
  belongs_to :academic_period
  has_many :sections, dependent: :destroy
  has_one :organization, through: :academic_period

  validates :name, presence: true
end
