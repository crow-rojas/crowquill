<script setup lang="ts">
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

import FormField from "./FormField.vue"

export interface SelectOption {
  label: string
  value: string
}

defineProps<{
  modelValue?: string
  label?: string
  error?: string
  required?: boolean
  placeholder?: string
  disabled?: boolean
  options: SelectOption[]
}>()

defineEmits<{
  "update:modelValue": [value: string]
}>()
</script>

<template>
  <FormField :label="label" :error="error" :required="required">
    <Select
      :model-value="modelValue"
      :disabled="disabled"
      :required="required"
      @update:model-value="$emit('update:modelValue', String($event ?? ''))"
    >
      <SelectTrigger>
        <SelectValue :placeholder="placeholder" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem
          v-for="option in options"
          :key="option.value"
          :value="option.value"
        >
          {{ option.label }}
        </SelectItem>
      </SelectContent>
    </Select>
  </FormField>
</template>
