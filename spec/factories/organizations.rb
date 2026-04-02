# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name { "Test Organization" }
    sequence(:slug) { |n| "test-org-#{n}" }
    settings { {} }
  end
end
