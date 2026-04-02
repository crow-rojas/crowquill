# frozen_string_literal: true

class OnboardingController < InertiaController
  skip_after_action :verify_authorized, only: %i[index]

  def index
    render inertia: "onboarding/index"
  end
end
