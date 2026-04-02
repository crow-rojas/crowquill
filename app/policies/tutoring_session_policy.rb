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
    tutor_or_above?
  end

  def edit?
    tutor_or_above?
  end

  def update?
    tutor_or_above?
  end

  def destroy?
    admin?
  end
end
