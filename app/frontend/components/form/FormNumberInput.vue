<script setup lang="ts">
import { Input } from "@/components/ui/input"

import FormField from "./FormField.vue"

defineProps<{
  modelValue?: number | string
  label?: string
  error?: string | string[]
  required?: boolean
  placeholder?: string
  disabled?: boolean
  min?: number
  max?: number
  step?: number
}>()

const emit = defineEmits<{
  "update:modelValue": [value: number | null]
}>()

function handleInput(value: string) {
  if (value === "") {
    emit("update:modelValue", null)
    return
  }
  const num = Number(value)
  emit("update:modelValue", isNaN(num) ? null : num)
}
</script>

<template>
  <FormField :label="label" :error="error" :required="required">
    <Input
      type="number"
      :model-value="modelValue != null ? String(modelValue) : ''"
      :placeholder="placeholder"
      :disabled="disabled"
      :required="required"
      :min="min"
      :max="max"
      :step="step"
      @update:model-value="(v: string | number) => handleInput(String(v))"
    />
  </FormField>
</template>
