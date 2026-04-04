<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import FormInput from "@/components/form/FormInput.vue"
import FormTextarea from "@/components/form/FormTextarea.vue"
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
  academicPeriodCoursesPath,
  academicPeriodPath,
  academicPeriodsPath,
  dashboardPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { AcademicPeriod } from "@/types/academic"

const props = defineProps<{
  academic_period: AcademicPeriod
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  {
    title: `${props.academic_period.year}-${props.academic_period.semester}`,
    href: academicPeriodPath(props.academic_period.id),
  },
  {
    title: t("courses.new"),
    href: academicPeriodCoursesPath(props.academic_period.id),
  },
]

const form = useForm({
  name: "",
  description: "",
})

function submit() {
  form
    .transform((data) => ({ course: data }))
    .post(academicPeriodCoursesPath(props.academic_period.id))
}
</script>

<template>
  <Head :title="t('courses.new')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-2xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("courses.new") }}</CardTitle>
        </CardHeader>

        <form @submit.prevent="submit">
          <CardContent class="space-y-4">
            <FormInput
              v-model="form.name"
              :label="t('courses.name')"
              :error="form.errors.name"
              required
            />
            <FormTextarea
              v-model="form.description"
              :label="t('courses.description')"
              :error="form.errors.description"
            />
          </CardContent>

          <CardFooter class="flex justify-end gap-2">
            <Button variant="outline" as-child>
              <Link :href="academicPeriodPath(academic_period.id)">
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
