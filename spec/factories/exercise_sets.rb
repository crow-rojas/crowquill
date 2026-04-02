# frozen_string_literal: true

FactoryBot.define do
  factory :exercise_set do
    course
    sequence(:title) { |n| "Exercise Set #{n}" }
    sequence(:week_number) { |n| n }
    content { "# Sample Exercise\n\nSolve $x^2 + 1 = 0$" }
    metadata { {} }
    published { false }

    trait :published do
      published { true }
    end
  end
end
