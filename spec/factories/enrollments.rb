# frozen_string_literal: true

FactoryBot.define do
  factory :enrollment do
    section
    user
    status { "active" }
    commitment_accepted_at { Time.current }
  end
end
