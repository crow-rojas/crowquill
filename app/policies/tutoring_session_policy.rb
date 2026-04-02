# frozen_string_literal: true

class TutoringSessionPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    membership.present?
  end

  def new?
    tutor_or_above?
  end

  def create?
    return true if admin?

    tutor_or_above? && record_section_owned_by_tutor?
  end

  def edit?
    tutor_or_above?
  end

  def update?
    return true if admin?

    tutor_or_above? && record_section_owned_by_tutor?
  end

  def destroy?
    admin?
  end

  private

  def record_section_owned_by_tutor?
    return true unless record&.respond_to?(:section)
    return true if record.section.nil?

    record.section.tutor_id == membership.user_id
  end
end
