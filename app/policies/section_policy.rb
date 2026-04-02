# frozen_string_literal: true

class SectionPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    membership.present?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def take_attendance?
    return true if admin?

    tutor_or_above? && record&.tutor_id == membership.user_id
  end
end
