# frozen_string_literal: true

class Section < ApplicationRecord
  belongs_to :course
  belongs_to :tutor, class_name: "User"

  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  validates :name, presence: true
  validates :max_students, presence: true, numericality: {greater_than: 0}
  validate :tutor_must_be_tutor_or_above

  private

  def tutor_must_be_tutor_or_above
    return unless tutor && course

    organization = course.academic_period&.organization
    return unless organization

    membership = tutor.memberships.find_by(organization: organization)
    unless membership&.tutor_or_above?
      errors.add(:tutor, "must have tutor or admin role")
    end
  end
end
