# frozen_string_literal: true

class ExerciseSetPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    membership.present?
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

  def publish?
    admin?
  end

  def unpublish?
    admin?
  end
end
