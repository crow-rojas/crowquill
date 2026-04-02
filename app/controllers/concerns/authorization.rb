# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  class NotAuthorizedError < StandardError; end

  included do
    attr_accessor :_authorized
  end

  def authorize!(record = nil, policy_class: nil)
    policy = (policy_class || policy_for(record)).new(Current.membership, record)
    action = "#{action_name}?"

    unless policy.public_send(action)
      raise NotAuthorizedError, "Not authorized to #{action_name} this resource"
    end

    self._authorized = true
    policy
  end

  def skip_authorization!
    self._authorized = true
  end

  private

  def policy_for(record)
    return record.class if record.is_a?(ApplicationRecord)

    "#{controller_name.classify}Policy".constantize
  rescue NameError
    ApplicationPolicy
  end

  def verify_authorized
    return if _authorized
    return if self.class.skip_verify_authorized_actions.include?(action_name.to_sym)

    raise NotAuthorizedError,
      "#{self.class}##{action_name} did not call authorize! or skip_authorization!"
  end

  def build_permissions
    membership = Current.membership
    return {} unless membership

    {
      manage_sections: membership.admin?,
      manage_exercises: membership.admin?,
      manage_academic_periods: membership.admin?,
      manage_courses: membership.admin?,
      take_attendance: membership.tutor_or_above?,
      view_attendance_statistics: membership.admin?,
      manage_enrollments: membership.admin?,
      create_ai_conversations: true
    }
  end

  module ClassMethods
    def skip_verify_authorized_actions
      @skip_verify_authorized_actions ||= Set.new
    end

    def skip_verify_authorized(*actions)
      skip_verify_authorized_actions.merge(actions)
    end
  end
end
