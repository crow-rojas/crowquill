# frozen_string_literal: true

class AttendancePolicy < ApplicationPolicy
  def index?
    can_manage_attendance?
  end

  def create?
    can_manage_attendance?
  end

  def update?
    can_manage_attendance?
  end

  def view_statistics?
    admin?
  end

  private

  def can_manage_attendance?
    return false unless membership.present?
    return true if admin?
    return false unless membership.tutor?

    section_owned_by_tutor?(section_for_record)
  end

  def section_for_record
    return record if record.is_a?(Section)
    return record.section if record&.respond_to?(:section)
    return record.tutoring_session.section if record&.respond_to?(:tutoring_session)

    nil
  end

  def section_owned_by_tutor?(section)
    section&.tutor_id == membership.user_id
  end
end
