# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :membership, :record

  def initialize(membership, record = nil)
    @membership = membership
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  private

  def admin?
    membership&.admin?
  end

  def tutor_or_above?
    membership&.tutor_or_above?
  end

  def admin_or_above?
    membership&.admin_or_above?
  end
end
