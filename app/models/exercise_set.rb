# frozen_string_literal: true

class ExerciseSet < ApplicationRecord
  belongs_to :course

  validates :title, presence: true
  validates :content, presence: true
  validates :week_number, numericality: {greater_than: 0}

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:week_number) }
end
