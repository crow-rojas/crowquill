# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    academic_period
    sequence(:name) { |n| "Course #{n}" }
    description { "A course description" }
  end
end
