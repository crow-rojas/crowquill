<script setup lang="ts">
import { Input } from "@/components/ui/input"

import FormField from "./FormField.vue"

defineProps<{
  modelValue?: string
  label?: string
  error?: string
  required?: boolean
  disabled?: boolean
  min?: string
  max?: string
}>()

defineEmits<{
  "update:modelValue": [value: string]
}>()
</script>

<template>
  <FormField :label="label" :error="error" :required="required">
    <Input
      type="date"
      :model-value="modelValue ?? ''"
      :disabled="disabled"
      :required="required"
      :min="min"
      :max="max"
      @update:model-value="$emit('update:modelValue', String($event))"
    />
  </FormField>
</template>
