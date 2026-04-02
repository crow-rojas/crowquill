# frozen_string_literal: true

class AiMessagesController < InertiaController
  def create
    # TODO: Move to ActiveJob for async processing. Currently blocks Puma thread during Claude API call.
    authorize! nil, policy_class: AiConversationPolicy
    conversation = Current.user.ai_conversations.find(params[:ai_conversation_id])

    user_message = conversation.ai_messages.create!(
      role: "user",
      content: message_params[:content],
      status: "complete"
    )

    assistant_message = conversation.ai_messages.create!(
      role: "assistant",
      content: "",
      status: "streaming"
    )

    service = AiTutorService.new(conversation, user_message.content)
    result = service.call

    if result[:error]
      assistant_message.update!(
        content: result[:content],
        status: "failed"
      )
    else
      assistant_message.update!(
        content: result[:content],
        status: "complete",
        input_tokens: result[:input_tokens],
        output_tokens: result[:output_tokens]
      )
    end

    redirect_to ai_conversation_path(conversation)
  end

  private

  def message_params
    params.require(:ai_message).permit(:content)
  end
end
