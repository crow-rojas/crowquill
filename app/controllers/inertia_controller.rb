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
      can: build_permissions,
      academic_period_context: build_academic_period_context,
      dev_user_switch: build_dev_user_switch
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
    flash[:alert] = t("flash.authorization.not_authorized")
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

  def build_academic_period_context
    return {active: nil, available: []} unless Current.organization

    academic_periods = Current.organization.academic_periods.order(start_date: :desc)
    active_period = academic_periods.find { |period| period.status == "active" }

    {
      active: active_period&.as_json(only: %i[id name start_date end_date status]),
      available: academic_periods.as_json(only: %i[id name start_date end_date status])
    }
  end

  def build_dev_user_switch
    enabled = dev_user_switch_enabled? && Current.organization.present?

    return {
      enabled: false,
      current_user_id: Current.user&.id,
      users: []
    } unless enabled

    role_order = Membership::ROLES.each_with_index.to_h

    users = Current.organization.memberships.includes(:user).filter_map do |membership|
      next unless membership.user

      {
        id: membership.user.id,
        name: membership.user.name,
        email: membership.user.email,
        role: membership.role
      }
    end.sort_by do |user|
      [
        role_order.fetch(user[:role], Membership::ROLES.length),
        user[:name].to_s.downcase
      ]
    end

    {
      enabled: true,
      current_user_id: Current.user&.id,
      users: users
    }
  end
end
