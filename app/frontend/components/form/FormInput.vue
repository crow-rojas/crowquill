<script setup lang="ts">
import { Input } from "@/components/ui/input"

import FormField from "./FormField.vue"

defineProps<{
  modelValue?: string | number
  label?: string
  error?: string | string[]
  required?: boolean
  type?: string
  placeholder?: string
  disabled?: boolean
  autocomplete?: string
}>()

defineEmits<{
  "update:modelValue": [value: string]
}>()
</script>

<template>
  <FormField :label="label" :error="error" :required="required">
    <Input
      :type="type ?? 'text'"
      :model-value="modelValue != null ? String(modelValue) : ''"
      :placeholder="placeholder"
      :disabled="disabled"
      :required="required"
      :autocomplete="autocomplete"
      @update:model-value="$emit('update:modelValue', String($event))"
    />
  </FormField>
</template>
