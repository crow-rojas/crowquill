# frozen_string_literal: true

class OnboardingController < InertiaController
  def index
    render inertia: "onboarding/index"
  end
end
