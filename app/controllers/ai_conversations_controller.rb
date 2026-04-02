# frozen_string_literal: true

class AiConversationsController < InertiaController
  def index
    authorize :ai_conversation, policy_class: AiConversationPolicy
    conversations = Current.user.ai_conversations.order(updated_at: :desc)

    render inertia: "AiConversations/Index", props: {
      conversations: conversations.as_json(only: %i[id title created_at updated_at])
    }
  end

  def show
    authorize :ai_conversation, policy_class: AiConversationPolicy
    conversation = Current.user.ai_conversations.find(params[:id])

    render inertia: "AiConversations/Show", props: {
      conversation: conversation.as_json(
        only: %i[id title exercise_set_id created_at updated_at],
        include: {
          ai_messages: {only: %i[id role content status input_tokens output_tokens created_at updated_at]}
        }
      )
    }
  end

  def create
    authorize :ai_conversation, policy_class: AiConversationPolicy

    if params[:ai_conversation][:exercise_set_id].present?
      exercise_sets = ExerciseSet.joins(course: {academic_period: :organization})
        .where(organizations: {id: Current.organization.id})
      exercise_sets = exercise_sets.published unless Current.membership&.admin?
      exercise_sets.find(params[:ai_conversation][:exercise_set_id])
    end

    conversation = Current.user.ai_conversations.build(conversation_params)

    if conversation.save
      redirect_to ai_conversation_path(conversation)
    else
      redirect_to ai_conversations_path, inertia: {errors: conversation.errors}
    end
  end

  private

  def conversation_params
    params.require(:ai_conversation).permit(:title, :exercise_set_id)
  end
end
