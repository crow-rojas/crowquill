<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
import { nextTick, onMounted, ref } from "vue"
import { useI18n } from "vue-i18n"

import ChatInput from "@/components/ChatInput.vue"
import ChatMessage from "@/components/ChatMessage.vue"
import { ScrollArea } from "@/components/ui/scroll-area"
import { useAiChat } from "@/composables/useAiChat"
import AppLayout from "@/layouts/AppLayout.vue"
import { aiConversationsPath } from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { AiConversation } from "@/types/academic"

const props = defineProps<{
  conversation: AiConversation & {
    ai_messages: NonNullable<AiConversation["ai_messages"]>
  }
}>()

const { t } = useI18n()
const { processing, sendMessage } = useAiChat(props.conversation.id)

const messagesEnd = ref<HTMLDivElement | null>(null)

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: "/dashboard" },
  { title: t("ai.title"), href: aiConversationsPath() },
  { title: props.conversation.title, href: "#" },
]

function scrollToBottom() {
  nextTick(() => {
    messagesEnd.value?.scrollIntoView({ behavior: "smooth" })
  })
}

onMounted(() => {
  scrollToBottom()
})
</script>

<template>
  <Head :title="conversation.title" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex h-[calc(100vh-10rem)] flex-col p-4 md:p-6">
      <h1 class="mb-4 text-2xl font-semibold tracking-tight">
        {{ conversation.title }}
      </h1>

      <ScrollArea class="flex-1 rounded-lg border p-4">
        <div
          v-if="conversation.ai_messages.length === 0"
          class="text-muted-foreground flex h-full items-center justify-center"
        >
          <p>{{ t("ai.chat_with_ai") }}</p>
        </div>

        <div v-else class="flex flex-col gap-4">
          <ChatMessage
            v-for="message in conversation.ai_messages"
            :key="message.id"
            :message="message"
          />
          <div ref="messagesEnd" />
        </div>
      </ScrollArea>

      <div class="mt-4">
        <ChatInput :disabled="processing" @send="sendMessage" />
      </div>
    </div>
  </AppLayout>
</template>
