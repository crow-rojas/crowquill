<script setup lang="ts">
import { useForm } from "@inertiajs/vue3"
import { ref } from "vue"
import { useI18n } from "vue-i18n"

import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { sectionEnrollmentsPath } from "@/routes"

const props = defineProps<{
  sectionId: number
  disabled?: boolean
}>()

const { t } = useI18n()
const open = ref(false)

const form = useForm({})

function handleEnroll() {
  form.post(sectionEnrollmentsPath(props.sectionId), {
    onSuccess: () => {
      open.value = false
    },
  })
}
</script>

<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <Button :disabled="disabled" size="sm">
        {{ t("enrollment.enroll") }}
      </Button>
    </DialogTrigger>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ t("enrollment.commitment_title") }}</DialogTitle>
        <DialogDescription>
          {{ t("enrollment.commitment_text") }}
        </DialogDescription>
      </DialogHeader>
      <DialogFooter>
        <Button variant="outline" @click="open = false">
          {{ t("common.cancel") }}
        </Button>
        <Button :disabled="form.processing" @click="handleEnroll">
          {{ t("enrollment.enroll") }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
