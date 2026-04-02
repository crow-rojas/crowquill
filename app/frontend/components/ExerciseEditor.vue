<script setup lang="ts">
import { useI18n } from "vue-i18n"

import MarkdownLatex from "@/components/MarkdownLatex.vue"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Textarea } from "@/components/ui/textarea"

const props = defineProps<{
  modelValue: string
}>()

const emit = defineEmits<{
  "update:modelValue": [value: string]
}>()

const { t } = useI18n()

function handleInput(event: Event) {
  const target = event.target as HTMLTextAreaElement
  emit("update:modelValue", target.value)
}
</script>

<template>
  <!-- Desktop: side-by-side -->
  <div class="hidden gap-4 md:grid md:grid-cols-2">
    <div class="flex flex-col gap-2">
      <label class="text-sm font-medium">{{ t("exercises.editor") }}</label>
      <Textarea
        :model-value="props.modelValue"
        class="min-h-[400px] font-mono text-sm"
        @input="handleInput"
      />
    </div>
    <div class="flex flex-col gap-2">
      <label class="text-sm font-medium">{{ t("exercises.preview") }}</label>
      <div
        class="border-input min-h-[400px] overflow-auto rounded-md border p-3"
      >
        <MarkdownLatex :content="props.modelValue" />
      </div>
    </div>
  </div>

  <!-- Mobile: tabs -->
  <div class="md:hidden">
    <Tabs default-value="editor">
      <TabsList class="w-full">
        <TabsTrigger value="editor" class="flex-1">
          {{ t("exercises.editor") }}
        </TabsTrigger>
        <TabsTrigger value="preview" class="flex-1">
          {{ t("exercises.preview") }}
        </TabsTrigger>
      </TabsList>
      <TabsContent value="editor">
        <Textarea
          :model-value="props.modelValue"
          class="min-h-[300px] font-mono text-sm"
          @input="handleInput"
        />
      </TabsContent>
      <TabsContent value="preview">
        <div
          class="border-input min-h-[300px] overflow-auto rounded-md border p-3"
        >
          <MarkdownLatex :content="props.modelValue" />
        </div>
      </TabsContent>
    </Tabs>
  </div>
</template>
