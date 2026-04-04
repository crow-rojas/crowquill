<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import ExerciseEditor from "@/components/ExerciseEditor.vue"
import FormInput from "@/components/form/FormInput.vue"
import FormNumberInput from "@/components/form/FormNumberInput.vue"
import FormSwitch from "@/components/form/FormSwitch.vue"
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
  courseExerciseSetsPath,
  coursePath,
  dashboardPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course } from "@/types/academic"

const props = defineProps<{
  course: Course
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  {
    title: t("nav.courses"),
    href: academicPeriodCoursesPath(props.course.academic_period_id),
  },
  { title: props.course.name, href: coursePath(props.course.id) },
  {
    title: t("exercises.title"),
    href: courseExerciseSetsPath(props.course.id),
  },
  { title: t("exercises.new"), href: courseExerciseSetsPath(props.course.id) },
]

const form = useForm({
  title: "",
  week_number: 1,
  content: "",
  published: false,
})

function submit() {
  form
    .transform((data) => ({ exercise_set: data }))
    .post(courseExerciseSetsPath(props.course.id))
}
</script>

<template>
  <Head :title="t('exercises.new')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-4xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("exercises.new") }}</CardTitle>
        </CardHeader>

        <form @submit.prevent="submit">
          <CardContent class="space-y-4">
            <FormInput
              v-model="form.title"
              :label="t('exercises.name')"
              :error="form.errors.title"
              required
            />
            <FormNumberInput
              v-model="form.week_number"
              :label="t('exercises.week_number')"
              :error="form.errors.week_number"
              :min="1"
              required
            />
            <div>
              <label class="mb-2 block text-sm font-medium">
                {{ t("exercises.content") }}
              </label>
              <ExerciseEditor v-model="form.content" />
              <p
                v-if="form.errors.content"
                class="text-destructive mt-1 text-sm"
              >
                {{ form.errors.content }}
              </p>
            </div>
            <FormSwitch
              v-model="form.published"
              :label="t('exercises.published')"
            />
          </CardContent>

          <CardFooter class="flex justify-end gap-2">
            <Button variant="outline" as-child>
              <Link :href="courseExerciseSetsPath(course.id)">
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
