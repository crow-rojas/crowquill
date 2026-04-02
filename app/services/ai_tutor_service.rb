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

  def initialize(conversation, user_message, chat: nil)
    @conversation = conversation
    @user_message = user_message
    @chat = chat
  end

  def call
    chat_instance = build_chat
    response = chat_instance.ask(@user_message)

    {
      content: response.content || "",
      input_tokens: response.input_tokens,
      output_tokens: response.output_tokens
    }
  rescue RubyLLM::Error => e
    Rails.logger.error("AiTutorService error: #{e.class} - #{e.message}")
    {content: "I'm sorry, I encountered an error. Please try again.", input_tokens: nil, output_tokens: nil, error: true}
  end

  private

  def build_chat
    c = @chat || RubyLLM.chat(model: model_id)
    c.with_instructions(system_prompt)

    build_history.each do |msg|
      c.add_message(role: msg[:role].to_sym, content: msg[:content])
    end

    c
  end

  def model_id
    ENV.fetch("AI_TUTOR_MODEL", "claude-haiku-4-5-20251001")
  end

  def system_prompt
    exercise_context = ""
    if conversation.exercise_set.present?
      exercise_context = "\n\nThe student is working on the following exercise set:\n#{conversation.exercise_set.content}"
    end

    SYSTEM_PROMPT + exercise_context
  end

  def build_history
    history = conversation.ai_messages
      .where(status: "complete")
      .order(:created_at)
      .pluck(:role, :content)
      .map { |role, content| {role: role, content: content} }

    # Exclude the last user message — chat.ask() will send it
    if history.any? && history.last[:role] == "user" && history.last[:content] == @user_message
      history[0...-1]
    else
      history
    end
  end
end
