<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import FormDatePicker from "@/components/form/FormDatePicker.vue"
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
import { academicPeriodsPath, dashboardPath } from "@/routes"
import type { BreadcrumbItem } from "@/types"

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: t("academic_periods.new"), href: academicPeriodsPath() },
]

const form = useForm({
  year: new Date().getFullYear() as number | undefined,
  semester: "1",
  name: "",
  start_date: "",
  end_date: "",
  status: "draft",
})

const semesterOptions = [
  { label: "1", value: "1" },
  { label: "2", value: "2" },
]

const statusOptions = [
  { label: t("academic_periods.statuses.draft"), value: "draft" },
  { label: t("academic_periods.statuses.active"), value: "active" },
  { label: t("academic_periods.statuses.archived"), value: "archived" },
]

function submit() {
  form
    .transform((data) => ({
      academic_period: {
        year: data.year,
        semester: Number(data.semester),
        name: data.name || null,
        start_date: data.start_date,
        end_date: data.end_date,
        status: data.status,
      },
    }))
    .post(academicPeriodsPath())
}
</script>

<template>
  <Head :title="t('academic_periods.new')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-2xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("academic_periods.new") }}</CardTitle>
        </CardHeader>

        <form @submit.prevent="submit">
          <CardContent class="space-y-4">
            <div class="grid gap-4 sm:grid-cols-2">
              <FormNumberInput
                v-model="form.year"
                :label="t('academic_periods.year')"
                :error="form.errors.year"
                :min="2001"
                :step="1"
                required
              />
              <FormSelect
                v-model="form.semester"
                :label="t('academic_periods.semester')"
                :error="form.errors.semester"
                :options="semesterOptions"
                required
              />
            </div>
            <FormInput
              v-model="form.name"
              :label="t('academic_periods.reference_name')"
              :error="form.errors.name"
              :placeholder="t('academic_periods.name_hint')"
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
              {{ t("common.create") }}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  </AppLayout>
</template>
