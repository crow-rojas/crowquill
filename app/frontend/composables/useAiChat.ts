import { useForm } from "@inertiajs/vue3"
import { ref } from "vue"

import { aiConversationAiMessagesPath } from "@/routes"

export function useAiChat(conversationId: number) {
  const processing = ref(false)

  const form = useForm({
    ai_message: {
      content: "",
    },
  })

  function sendMessage(content: string) {
    form.ai_message.content = content
    processing.value = true

    form.post(aiConversationAiMessagesPath(conversationId), {
      preserveScroll: true,
      onFinish() {
        processing.value = false
        form.reset()
      },
    })
  }

  return {
    processing,
    sendMessage,
  }
}
