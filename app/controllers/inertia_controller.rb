# frozen_string_literal: true

class InertiaController < ApplicationController
  include Authorization

  before_action :resolve_membership
  before_action :require_membership
  after_action :verify_authorized

  rescue_from Authorization::NotAuthorizedError, with: :handle_not_authorized

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
end
