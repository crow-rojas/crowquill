<script setup lang="ts">
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"

import FormField from "./FormField.vue"

defineProps<{
  modelValue?: boolean
  label?: string
  description?: string
  error?: string | string[]
  disabled?: boolean
}>()

defineEmits<{
  "update:modelValue": [value: boolean]
}>()
</script>

<template>
  <FormField :error="error">
    <div class="flex items-center justify-between gap-4">
      <div>
        <Label v-if="label" class="font-normal">{{ label }}</Label>
        <p v-if="description" class="text-muted-foreground text-sm">
          {{ description }}
        </p>
      </div>
      <Switch
        :model-value="modelValue ?? false"
        :disabled="disabled"
        @update:model-value="$emit('update:modelValue', $event)"
      />
    </div>
  </FormField>
</template>
