<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import FormInput from "@/components/form/FormInput.vue"
import FormNumberInput from "@/components/form/FormNumberInput.vue"
import FormSelect from "@/components/form/FormSelect.vue"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import AppLayout from "@/layouts/AppLayout.vue"
import { academicPeriodsPath, dashboardPath, sectionPath } from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Section } from "@/types/academic"

interface Tutor {
  id: number
  name: string
  email: string
}

const props = defineProps<{
  section: Section
  tutors: Tutor[]
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: t("sections.edit"), href: "#" },
]

const tutorOptions = props.tutors.map((tutor) => ({
  label: `${tutor.name} (${tutor.email})`,
  value: String(tutor.id),
}))

const form = useForm({
  name: props.section.name,
  max_students: props.section.max_students,
  tutor_id: String(props.section.tutor_id),
  schedule: props.section.schedule as Record<string, string>,
})

function submit() {
  form
    .transform((data) => ({
      ...data,
      tutor_id: Number(data.tutor_id),
    }))
    .patch(sectionPath(props.section.id))
}
</script>

<template>
  <Head :title="t('sections.edit')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-2xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("sections.edit") }}</CardTitle>
        </CardHeader>

        <form @submit.prevent="submit">
          <CardContent class="space-y-4">
            <FormInput
              v-model="form.name"
              :label="t('sections.name')"
              :error="form.errors.name"
              required
            />
            <FormSelect
              v-model="form.tutor_id"
              :label="t('sections.tutor')"
              :error="form.errors.tutor_id"
              :options="tutorOptions"
              :placeholder="t('sections.select_tutor')"
              required
            />
            <FormNumberInput
              v-model="form.max_students"
              :label="t('sections.max_students')"
              :error="form.errors.max_students"
              :min="1"
              :max="50"
              required
            />
          </CardContent>

          <CardFooter class="flex justify-end gap-2">
            <Button variant="outline" as-child>
              <Link :href="sectionPath(section.id)">
                {{ t("common.cancel") }}
              </Link>
            </Button>
            <Button type="submit" :disabled="form.processing">
              {{ t("common.save") }}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  </AppLayout>
</template>
