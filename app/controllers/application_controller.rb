# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :set_current_request_details
  before_action :authenticate

  private

  def authenticate
    redirect_to sign_in_path unless perform_authentication
  end

  def require_no_authentication
    return unless perform_authentication

    flash[:notice] = t("flash.auth.already_signed_in")
    redirect_to root_path
  end

  def perform_authentication
    Current.session ||= Session.find_by_id(cookies.signed[:session_token])
  end

  def resolve_membership
    return unless Current.user

    memberships = Current.user.memberships.includes(:organization).to_a
    return if memberships.empty?

    default_org_slug = ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")
    preferred_org_slug = dev_user_switch_enabled? ? cookies.signed[:dev_org_slug].presence : nil

    Current.membership =
      membership_for_slug(memberships, preferred_org_slug) ||
      membership_for_slug(memberships, default_org_slug) ||
      memberships.first
  end

  def set_locale
    locale = cookies[:app_lang].to_s
    I18n.locale = locale.in?(%w[es en]) ? locale : I18n.default_locale
  end

  def dev_user_switch_enabled?
    return false unless Rails.env.development?

    ActiveModel::Type::Boolean.new.cast(ENV.fetch("DEV_USER_SWITCH_ENABLED", false))
  end

  def safe_internal_path(path)
    return nil if path.blank?

    uri = URI.parse(path)
    return nil if uri.scheme.present? || uri.host.present?

    candidate = uri.to_s
    return nil unless candidate.start_with?("/")

    candidate
  rescue URI::InvalidURIError
    nil
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  def membership_for_slug(memberships, slug)
    return nil if slug.blank?

    memberships.find { |membership| membership.organization&.slug == slug }
  end
end
