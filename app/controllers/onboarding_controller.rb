# frozen_string_literal: true

class OnboardingController < InertiaController
  skip_verify_authorized :index

  def index
    render inertia: "onboarding/index"
  end
end
