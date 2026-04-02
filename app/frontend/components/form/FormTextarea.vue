<script setup lang="ts">
import { Textarea } from "@/components/ui/textarea"

import FormField from "./FormField.vue"

defineProps<{
  modelValue?: string
  label?: string
  error?: string | string[]
  required?: boolean
  placeholder?: string
  disabled?: boolean
  rows?: number
}>()

defineEmits<{
  "update:modelValue": [value: string]
}>()
</script>

<template>
  <FormField :label="label" :error="error" :required="required">
    <Textarea
      :model-value="modelValue ?? ''"
      :placeholder="placeholder"
      :disabled="disabled"
      :required="required"
      :rows="rows ?? 3"
      @update:model-value="$emit('update:modelValue', String($event))"
    />
  </FormField>
</template>
