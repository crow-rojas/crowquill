# frozen_string_literal: true

class AiConversationPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    membership.present?
  end

  def create?
    membership.present?
  end
end
