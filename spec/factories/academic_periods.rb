# frozen_string_literal: true

FactoryBot.define do
  factory :academic_period do
    organization
    sequence(:year) { |n| 2026 + n }
    semester { 1 }
    name { nil }
    start_date { Date.new(2026, 3, 1) }
    end_date { Date.new(2026, 7, 31) }
    status { "draft" }

    trait :active do
      status { "active" }
    end

    trait :archived do
      status { "archived" }
    end
  end
end
