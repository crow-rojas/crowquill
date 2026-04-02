# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    tutoring_session
    enrollment
    status { "absent" }
  end
end
