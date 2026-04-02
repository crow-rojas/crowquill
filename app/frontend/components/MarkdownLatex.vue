<script setup lang="ts">
import { katex as katexPlugin } from "@mdit/plugin-katex"
import DOMPurify from "dompurify"
import MarkdownIt from "markdown-it"
import { computed } from "vue"

const props = defineProps<{
  content: string
}>()

const md = MarkdownIt({
  html: false,
  linkify: true,
  typographer: true,
})

md.use(katexPlugin, {
  throwOnError: false,
})

const rendered = computed(() => {
  const raw = md.render(props.content)
  return DOMPurify.sanitize(raw)
})
</script>

<template>
  <!-- eslint-disable-next-line vue/no-v-html -->
  <div class="prose dark:prose-invert max-w-none" v-html="rendered" />
</template>
