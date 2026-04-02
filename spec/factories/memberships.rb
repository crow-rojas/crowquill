# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    user
    organization
    role { "tutorado" }

    trait :admin do
      role { "admin" }
    end

    trait :tutor do
      role { "tutor" }
    end

    trait :tutorado do
      role { "tutorado" }
    end
  end
end
