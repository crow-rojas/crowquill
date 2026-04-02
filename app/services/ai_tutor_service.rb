# frozen_string_literal: true

class AiTutorService
  SYSTEM_PROMPT = <<~PROMPT
    You are a Socratic math tutor. Your role is to guide students through problems step-by-step without giving direct answers. Ask probing questions to help them discover the solution themselves.

    Guidelines:
    - Never provide the final answer directly
    - Break problems into smaller steps
    - Use LaTeX notation for math expressions (e.g., $x^2 + 1$, $$\\int_0^1 f(x)\\,dx$$)
    - If the student is stuck, give a hint rather than the answer
    - Encourage and praise progress
    - Respond in the same language the student uses
    - If the student asks something unrelated to math, gently redirect to the topic
  PROMPT

  attr_reader :conversation, :user_message

  def initialize(conversation, user_message, client: nil)
    @conversation = conversation
    @user_message = user_message
    @client = client
  end

  def call
    messages = build_messages
    response = client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 2048,
      system: system_prompt,
      messages: messages
    )

    content = response.content&.first&.text || ""
    input_tokens = response.usage&.input_tokens
    output_tokens = response.usage&.output_tokens

    {content: content, input_tokens: input_tokens, output_tokens: output_tokens}
  rescue Anthropic::Errors::Error => e
    Rails.logger.error("AiTutorService error: #{e.class} - #{e.message}")
    {content: "I'm sorry, I encountered an error. Please try again.", input_tokens: nil, output_tokens: nil, error: true}
  end

  private

  def client
    @client ||= Anthropic::Client.new(api_key: api_key)
  end

  def api_key
    Rails.application.credentials.dig(:anthropic, :api_key) || ENV["ANTHROPIC_API_KEY"]
  end

  def system_prompt
    exercise_context = ""
    if conversation.exercise_set.present?
      exercise_context = "\n\nThe student is working on the following exercise set:\n#{conversation.exercise_set.content}"
    end

    SYSTEM_PROMPT + exercise_context
  end

  def build_messages
    history = conversation.ai_messages
      .where(status: "complete")
      .order(:created_at)
      .pluck(:role, :content)

    messages = history.map { |role, content| {role: role, content: content} }
    messages << {role: "user", content: user_message}
    messages
  end
end
