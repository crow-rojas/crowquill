# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  def index?
    membership.present?
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
