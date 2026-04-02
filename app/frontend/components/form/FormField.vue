<script setup lang="ts">
import { computed } from "vue"

const props = defineProps<{
  label?: string
  error?: string | string[]
  required?: boolean
}>()

const errorMessage = computed(() => {
  if (!props.error) return undefined
  return Array.isArray(props.error) ? props.error[0] : props.error
})
</script>

<template>
  <div class="grid gap-2">
    <label
      v-if="label"
      class="text-sm leading-none font-medium peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
    >
      {{ label }}
      <span v-if="required" class="text-destructive ml-0.5">*</span>
    </label>
    <slot />
    <p v-if="errorMessage" class="text-destructive text-sm">
      {{ errorMessage }}
    </p>
  </div>
</template>
