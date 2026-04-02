<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import FormDatePicker from "@/components/form/FormDatePicker.vue"
import FormInput from "@/components/form/FormInput.vue"
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
import { academicPeriodPath, academicPeriodsPath } from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { AcademicPeriod } from "@/types/academic"

const props = defineProps<{
  academic_period: AcademicPeriod
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: "/dashboard" },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: t("academic_periods.edit"), href: "#" },
]

const form = useForm({
  name: props.academic_period.name,
  start_date: props.academic_period.start_date,
  end_date: props.academic_period.end_date,
  status: props.academic_period.status,
})

const statusOptions = [
  { label: t("academic_periods.statuses.draft"), value: "draft" },
  { label: t("academic_periods.statuses.active"), value: "active" },
  { label: t("academic_periods.statuses.archived"), value: "archived" },
]

function submit() {
  form.patch(academicPeriodPath(props.academic_period.id))
}
</script>

<template>
  <Head :title="t('academic_periods.edit')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-2xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("academic_periods.edit") }}</CardTitle>
        </CardHeader>

        <form @submit.prevent="submit">
          <CardContent class="space-y-4">
            <FormInput
              v-model="form.name"
              :label="t('academic_periods.name')"
              :error="form.errors.name"
              required
            />
            <div class="grid gap-4 sm:grid-cols-2">
              <FormDatePicker
                v-model="form.start_date"
                :label="t('academic_periods.start_date')"
                :error="form.errors.start_date"
                required
              />
              <FormDatePicker
                v-model="form.end_date"
                :label="t('academic_periods.end_date')"
                :error="form.errors.end_date"
                required
              />
            </div>
            <FormSelect
              v-model="form.status"
              :label="t('academic_periods.status')"
              :error="form.errors.status"
              :options="statusOptions"
              required
            />
          </CardContent>

          <CardFooter class="flex justify-end gap-2">
            <Button variant="outline" as-child>
              <Link :href="academicPeriodsPath()">
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
