import { useForm } from "@inertiajs/vue3"
import { ref } from "vue"

import { aiConversationAiMessagesPath } from "@/routes"

export function useAiChat(conversationId: number) {
  const processing = ref(false)
  const error = ref<string | null>(null)

  const form = useForm({
    ai_message: {
      content: "",
    },
  })

  function sendMessage(content: string) {
    form.ai_message.content = content
    processing.value = true
    error.value = null

    form.post(aiConversationAiMessagesPath(conversationId), {
      preserveScroll: true,
      onError(errors) {
        error.value =
          Object.values(errors).flat().join(", ") || "An error occurred"
      },
      onFinish() {
        processing.value = false
        form.reset()
      },
    })
  }

  return {
    processing,
    error,
    errors: form.errors,
    sendMessage,
  }
}
