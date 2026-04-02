# frozen_string_literal: true

class AttendancePolicy < ApplicationPolicy
  def index?
    tutor_or_above?
  end

  def create?
    tutor_or_above?
  end

  def update?
    tutor_or_above?
  end

  def view_statistics?
    admin?
  end
end
