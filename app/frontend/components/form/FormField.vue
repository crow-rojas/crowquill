<script setup lang="ts">
defineProps<{
  label?: string
  error?: string
  required?: boolean
}>()
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
    <p v-if="error" class="text-destructive text-sm">{{ error }}</p>
  </div>
</template>
