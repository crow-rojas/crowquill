<script setup lang="ts">
import { AlertCircle, Bot, User } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import MarkdownLatex from "@/components/MarkdownLatex.vue"
import type { AiMessage } from "@/types/academic"

const props = defineProps<{
  message: AiMessage
}>()

const { t } = useI18n()
</script>

<template>
  <div
    class="flex gap-3"
    :class="[props.message.role === 'user' ? 'justify-end' : 'justify-start']"
  >
    <div
      v-if="props.message.role === 'assistant'"
      class="bg-muted flex h-8 w-8 shrink-0 items-center justify-center rounded-full"
    >
      <Bot class="h-4 w-4" />
    </div>

    <div
      class="max-w-[80%] rounded-lg px-4 py-3"
      :class="[
        props.message.role === 'user'
          ? 'bg-primary text-primary-foreground'
          : 'bg-muted',
      ]"
    >
      <div
        v-if="props.message.status === 'streaming'"
        class="flex items-center gap-2"
      >
        <span class="text-muted-foreground animate-pulse text-sm">
          {{ t("ai.thinking") }}
        </span>
      </div>

      <div
        v-else-if="props.message.status === 'failed'"
        class="flex items-center gap-2"
      >
        <AlertCircle class="h-4 w-4 text-red-500" />
        <span class="text-sm text-red-500">{{ t("ai.error_occurred") }}</span>
      </div>

      <template v-else>
        <MarkdownLatex
          v-if="props.message.role === 'assistant'"
          :content="props.message.content"
        />
        <p v-else class="text-sm whitespace-pre-wrap">
          {{ props.message.content }}
        </p>
      </template>
    </div>

    <div
      v-if="props.message.role === 'user'"
      class="bg-primary flex h-8 w-8 shrink-0 items-center justify-center rounded-full"
    >
      <User class="text-primary-foreground h-4 w-4" />
    </div>
  </div>
</template>
