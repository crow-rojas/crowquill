<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import FormDatePicker from "@/components/form/FormDatePicker.vue"
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
import {
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  sectionPath,
  sectionTutoringSessionsPath,
  tutoringSessionPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, Section, TutoringSession } from "@/types/academic"

const props = defineProps<{
  tutoring_session: TutoringSession & {
    section: Section & { course: Course }
  }
}>()

const { t } = useI18n()

const section = props.tutoring_session.section
const course = section.course!

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: course.name, href: coursePath(course.id) },
  { title: section.name, href: sectionPath(section.id) },
  {
    title: t("sessions.title"),
    href: sectionTutoringSessionsPath(section.id),
  },
  {
    title: t("sessions.edit"),
    href: tutoringSessionPath(props.tutoring_session.id),
  },
]

const statusOptions = [
  { label: t("sessions.statuses.scheduled"), value: "scheduled" },
  { label: t("sessions.statuses.completed"), value: "completed" },
  { label: t("sessions.statuses.cancelled"), value: "cancelled" },
]

const form = useForm({
  date: props.tutoring_session.date,
  status: props.tutoring_session.status,
})

function submit() {
  form
    .transform((data) => ({ tutoring_session: data }))
    .patch(tutoringSessionPath(props.tutoring_session.id))
}
</script>

<template>
  <Head :title="t('sessions.edit')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-2xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("sessions.edit") }}</CardTitle>
        </CardHeader>

        <form @submit.prevent="submit">
          <CardContent class="space-y-4">
            <FormDatePicker
              v-model="form.date"
              :label="t('sessions.date')"
              :error="form.errors.date"
              required
            />
            <FormSelect
              v-model="form.status"
              :label="t('sessions.status')"
              :error="form.errors.status"
              :options="statusOptions"
              required
            />
          </CardContent>

          <CardFooter class="flex justify-end gap-2">
            <Button variant="outline" as-child>
              <Link :href="tutoringSessionPath(tutoring_session.id)">
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
