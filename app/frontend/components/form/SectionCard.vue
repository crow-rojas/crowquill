<script setup lang="ts">
import { ChevronDown } from "lucide-vue-next"
import { ref } from "vue"

import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible"

defineProps<{
  title: string
  defaultOpen?: boolean
}>()

const open = ref(true)
</script>

<template>
  <Collapsible v-model:open="open" :default-open="defaultOpen ?? true">
    <div class="rounded-lg border">
      <CollapsibleTrigger as-child>
        <button
          class="hover:bg-muted/50 flex w-full items-center justify-between px-4 py-3 text-left font-medium"
        >
          <span>{{ title }}</span>
          <ChevronDown
            class="h-4 w-4 shrink-0 transition-transform duration-200"
            :class="{ 'rotate-180': !open }"
          />
        </button>
      </CollapsibleTrigger>

      <CollapsibleContent>
        <div class="space-y-4 border-t px-4 py-4">
          <slot />
        </div>
      </CollapsibleContent>
    </div>
  </Collapsible>
</template>
