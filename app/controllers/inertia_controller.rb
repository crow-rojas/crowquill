# frozen_string_literal: true

class InertiaController < ApplicationController
  include Pundit::Authorization

  before_action :resolve_membership
  before_action :require_membership
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized

  inertia_config default_render: true
  inertia_share auth: -> {
    {
      user: Current.user&.as_json(only: %i[id name email verified created_at updated_at]),
      session: Current.session&.as_json(only: %i[id]),
      membership: Current.membership&.as_json(only: %i[id role]),
      current_role: Current.membership&.role,
      can: build_permissions
    }
  }

  private

  def pundit_user
    Current.membership
  end

  def require_membership
    return if Current.membership
    return if self.class.skip_membership_controllers.include?(controller_name)

    redirect_to onboarding_path
  end

  def handle_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: dashboard_path)
  end

  def self.skip_membership_controllers
    %w[onboarding]
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
end
