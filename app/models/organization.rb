# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :academic_periods, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  normalizes :slug, with: -> { _1.strip.downcase.gsub(/[^a-z0-9\-]/, "-") }
end
