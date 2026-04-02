<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import FormDatePicker from "@/components/form/FormDatePicker.vue"
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
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, Section } from "@/types/academic"

const props = defineProps<{
  section: Section & { course: Course }
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  {
    title: props.section.course.name,
    href: coursePath(props.section.course.id),
  },
  {
    title: props.section.name,
    href: sectionPath(props.section.id),
  },
  {
    title: t("sessions.title"),
    href: sectionTutoringSessionsPath(props.section.id),
  },
  {
    title: t("sessions.new"),
    href: "#",
  },
]

const form = useForm({
  date: "",
})

function submit() {
  form.post(sectionTutoringSessionsPath(props.section.id))
}
</script>

<template>
  <Head :title="t('sessions.new')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-2xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("sessions.new") }}</CardTitle>
        </CardHeader>

        <form @submit.prevent="submit">
          <CardContent class="space-y-4">
            <FormDatePicker
              v-model="form.date"
              :label="t('sessions.date')"
              :error="form.errors.date"
              required
            />
          </CardContent>

          <CardFooter class="flex justify-end gap-2">
            <Button variant="outline" as-child>
              <Link :href="sectionTutoringSessionsPath(section.id)">
                {{ t("common.cancel") }}
              </Link>
            </Button>
            <Button type="submit" :disabled="form.processing">
              {{ t("common.create") }}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  </AppLayout>
</template>
