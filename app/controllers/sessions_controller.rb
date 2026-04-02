# frozen_string_literal: true

class SessionsController < InertiaController
  skip_before_action :authenticate, only: %i[new create]
  skip_before_action :require_membership
  before_action :require_no_authentication, only: %i[new create]
  before_action :set_session, only: :destroy
  before_action :require_membership, only: :switch
  before_action :ensure_dev_user_switch_enabled!, only: :switch
  skip_after_action :verify_authorized, only: %i[new create destroy switch]

  def new
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      @session = user.sessions.create!
      cookies.signed.permanent[:session_token] = session_cookie_options(@session.id)

      redirect_to dashboard_path, notice: t("flash.sessions.signed_in")
    else
      redirect_to sign_in_path, alert: t("flash.sessions.invalid_credentials")
    end
  end

  def switch
    target_membership = Current.organization.memberships.includes(:user).find_by(user_id: params[:user_id])

    unless target_membership&.user
      redirect_to dashboard_path, alert: t("flash.sessions.switch_user_unavailable")
      return
    end

    switched_session = target_membership.user.sessions.create!
    cookies.signed.permanent[:session_token] = session_cookie_options(switched_session.id)
    Current.session = switched_session

    redirect_to switch_return_path, notice: t("flash.sessions.switched_user", email: target_membership.user.email)
  end

  def destroy
    @session.destroy!
    Current.session = nil
    redirect_to settings_sessions_path, notice: t("flash.sessions.logged_out"), inertia: {clear_history: true}
  end

  private

  def ensure_dev_user_switch_enabled!
    return if dev_user_switch_enabled?

    head :not_found
  end

  def switch_return_path
    safe_internal_path(params[:return_to]) || dashboard_path
  end

  def session_cookie_options(session_id)
    {
      value: session_id,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

  def set_session
    @session = Current.user.sessions.find(params[:id])
  end
end
