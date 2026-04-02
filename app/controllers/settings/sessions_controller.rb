# frozen_string_literal: true

class Settings::SessionsController < InertiaController
  skip_before_action :require_membership
  skip_verify_authorized :index

  def index
    sessions = Current.user.sessions.order(created_at: :desc)

    render inertia: {sessions: sessions.as_json(only: %i[id user_agent ip_address created_at])}
  end
end
