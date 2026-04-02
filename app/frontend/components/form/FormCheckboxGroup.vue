<script setup lang="ts">
import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"

import FormField from "./FormField.vue"

export interface CheckboxOption {
  label: string
  value: string
}

const props = defineProps<{
  modelValue?: string[]
  label?: string
  error?: string
  required?: boolean
  disabled?: boolean
  options: CheckboxOption[]
}>()

const emit = defineEmits<{
  "update:modelValue": [value: string[]]
}>()

function toggle(value: string) {
  const current = props.modelValue ?? []
  const next = current.includes(value)
    ? current.filter((v) => v !== value)
    : [...current, value]
  emit("update:modelValue", next)
}
</script>

<template>
  <FormField :label="label" :error="error" :required="required">
    <div class="flex flex-col gap-2">
      <div
        v-for="option in options"
        :key="option.value"
        class="flex items-center gap-2"
      >
        <Checkbox
          :id="`checkbox-${option.value}`"
          :checked="(modelValue ?? []).includes(option.value)"
          :disabled="disabled"
          @update:checked="toggle(option.value)"
        />
        <Label :for="`checkbox-${option.value}`" class="font-normal">
          {{ option.label }}
        </Label>
      </div>
    </div>
  </FormField>
</template>
