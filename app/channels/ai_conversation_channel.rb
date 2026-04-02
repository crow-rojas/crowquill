# frozen_string_literal: true

class AiConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = AiConversation.find_by(id: params[:id])

    if conversation && conversation.user_id == current_user.id
      stream_from "ai_conversation_#{conversation.id}"
    else
      reject
    end
  end
end
