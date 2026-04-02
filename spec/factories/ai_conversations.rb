# frozen_string_literal: true

FactoryBot.define do
  factory :ai_conversation do
    user
    exercise_set { nil }
    sequence(:title) { |n| "Conversation #{n}" }

    trait :with_exercise_set do
      exercise_set
    end
  end
end
