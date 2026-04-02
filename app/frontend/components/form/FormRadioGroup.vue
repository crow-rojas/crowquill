<script setup lang="ts">
import { Label } from "@/components/ui/label"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"

import FormField from "./FormField.vue"

export interface RadioOption {
  label: string
  value: string
}

defineProps<{
  modelValue?: string
  label?: string
  error?: string
  required?: boolean
  disabled?: boolean
  options: RadioOption[]
}>()

defineEmits<{
  "update:modelValue": [value: string]
}>()
</script>

<template>
  <FormField :label="label" :error="error" :required="required">
    <RadioGroup
      :model-value="modelValue"
      :disabled="disabled"
      :required="required"
      @update:model-value="$emit('update:modelValue', String($event ?? ''))"
    >
      <div
        v-for="option in options"
        :key="option.value"
        class="flex items-center gap-2"
      >
        <RadioGroupItem :id="`radio-${option.value}`" :value="option.value" />
        <Label :for="`radio-${option.value}`" class="font-normal">
          {{ option.label }}
        </Label>
      </div>
    </RadioGroup>
  </FormField>
</template>
