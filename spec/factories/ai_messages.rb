# frozen_string_literal: true

FactoryBot.define do
  factory :ai_message do
    ai_conversation
    role { "user" }
    content { "Help me solve this equation" }
    status { "complete" }

    trait :assistant do
      role { "assistant" }
      content { "Let's break this problem down step by step." }
    end

    trait :streaming do
      status { "streaming" }
    end

    trait :failed do
      status { "failed" }
    end
  end
end
