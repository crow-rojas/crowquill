# frozen_string_literal: true

class SectionPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    return false unless membership.present?
    return true if admin?
    return false unless record

    if membership.tutor?
      record.tutor_id == membership.user_id
    elsif membership.tutorado?
      enrolled_in_section?(record) || section_has_capacity?(record)
    else
      false
    end
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
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

  private

  def enrolled_in_section?(section)
    section.enrollments.active.exists?(user_id: membership.user_id)
  end

  def section_has_capacity?(section)
    section.enrollments.active.count < section.max_students
  end
end
