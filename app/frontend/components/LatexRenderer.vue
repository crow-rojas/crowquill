<script setup lang="ts">
import DOMPurify from "dompurify"
import katex from "katex"
import { computed } from "vue"

const props = withDefaults(
  defineProps<{
    expression: string
    displayMode?: boolean
  }>(),
  {
    displayMode: false,
  },
)

const rendered = computed(() => {
  try {
    const html = katex.renderToString(props.expression, {
      displayMode: props.displayMode,
      throwOnError: false,
    })
    return { html: DOMPurify.sanitize(html), error: null }
  } catch {
    return { html: "", error: `Invalid LaTeX: ${props.expression}` }
  }
})
</script>

<template>
  <span v-if="rendered.error" class="text-destructive text-sm">
    {{ rendered.error }}
  </span>
  <!-- eslint-disable-next-line vue/no-v-html -->
  <span v-else v-html="rendered.html" />
</template>
