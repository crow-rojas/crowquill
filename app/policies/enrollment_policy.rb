# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  def index?
    return false unless membership.present?
    return true if admin?
    return false unless record.is_a?(Section)

    if membership.tutor?
      record.tutor_id == membership.user_id
    elsif membership.tutorado?
      record.enrollments.active.exists?(user_id: membership.user_id)
    else
      false
    end
  end

  def create?
    return true if admin?

    membership&.tutorado?
  end

  def update?
    return true if admin?

    membership&.tutorado? && record&.user_id == membership.user_id
  end

  def destroy?
    admin?
  end
end
