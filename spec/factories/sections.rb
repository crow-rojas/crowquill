# frozen_string_literal: true

FactoryBot.define do
  factory :section do
    course
    tutor factory: :user
    sequence(:name) { |n| "Section #{n}" }
    schedule { {} }
    max_students { 12 }
  end
end
