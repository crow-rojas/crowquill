# frozen_string_literal: true

class Settings::LanguageController < InertiaController
  skip_before_action :require_membership
  skip_after_action :verify_authorized

  def show
    render inertia: "settings/language"
  end
end
