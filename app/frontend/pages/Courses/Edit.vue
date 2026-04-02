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
import { academicPeriodsPath, coursePath } from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course } from "@/types/academic"

const props = defineProps<{
  course: Course
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: "/dashboard" },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: t("courses.edit"), href: "#" },
]

const form = useForm({
  name: props.course.name,
  description: props.course.description ?? "",
})

function submit() {
  form.patch(coursePath(props.course.id))
}
</script>

<template>
  <Head :title="t('courses.edit')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-2xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("courses.edit") }}</CardTitle>
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
              <Link :href="coursePath(course.id)">
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
