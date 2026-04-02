<script setup lang="ts">
import { Send } from "lucide-vue-next"
import { ref } from "vue"
import { useI18n } from "vue-i18n"

import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"

const props = defineProps<{
  disabled?: boolean
}>()

const emit = defineEmits<{
  send: [content: string]
}>()

const { t } = useI18n()
const content = ref("")

function handleKeyDown(event: KeyboardEvent) {
  if (event.key === "Enter" && !event.shiftKey) {
    event.preventDefault()
    handleSend()
  }
}

function handleSend() {
  const trimmed = content.value.trim()
  if (!trimmed || props.disabled) return

  emit("send", trimmed)
  content.value = ""
}
</script>

<template>
  <div class="flex gap-2">
    <Textarea
      v-model="content"
      :placeholder="t('ai.type_message')"
      :disabled="props.disabled"
      class="min-h-[44px] resize-none"
      rows="1"
      @keydown="handleKeyDown"
    />
    <Button
      size="icon"
      :disabled="props.disabled || !content.trim()"
      class="h-[44px] w-[44px] shrink-0"
      @click="handleSend"
    >
      <Send class="h-4 w-4" />
      <span class="sr-only">{{ t("ai.send") }}</span>
    </Button>
  </div>
</template>
