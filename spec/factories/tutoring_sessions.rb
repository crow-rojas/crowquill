# frozen_string_literal: true

FactoryBot.define do
  factory :tutoring_session do
    section
    date { Date.current }
    status { "scheduled" }
  end
end
