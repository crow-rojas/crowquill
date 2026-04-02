# frozen_string_literal: true

class TutoringSessionPolicy < ApplicationPolicy
  def index?
    can_read_section?(section_for_record)
  end

  def show?
    can_read_section?(section_for_record)
  end

  def new?
    return true if admin?

    membership&.tutor? && section_owned_by_tutor?(section_for_record)
  end

  def create?
    new?
  end

  def edit?
    update?
  end

  def update?
    return true if admin?

    membership&.tutor? && section_owned_by_tutor?(section_for_record)
  end

  def destroy?
    admin?
  end

  private

  def section_for_record
    return record if record.is_a?(Section)
    return record.section if record&.respond_to?(:section)

    nil
  end

  def can_read_section?(section)
    return false unless membership.present?
    return true if admin?
    return false unless section

    if membership.tutor?
      section_owned_by_tutor?(section)
    elsif membership.tutorado?
      enrolled_in_section?(section)
    else
      false
    end
  end

  def section_owned_by_tutor?(section)
    section&.tutor_id == membership.user_id
  end

  def enrolled_in_section?(section)
    section.enrollments.active.exists?(user_id: membership.user_id)
  end
end
