# frozen_string_literal: true

FactoryBot.define do
  factory :academic_period do
    organization
    name { "2026 Semester 1" }
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
