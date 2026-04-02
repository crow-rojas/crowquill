# frozen_string_literal: true

class HomeController < InertiaController
  skip_before_action :authenticate
  skip_before_action :require_membership
  before_action :perform_authentication
  skip_after_action :verify_authorized, only: %i[index]

  def index
  end
end
