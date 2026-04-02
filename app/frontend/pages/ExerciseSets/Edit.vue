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
  academicPeriodsPath,
  courseExerciseSetsPath,
  coursePath,
  dashboardPath,
  exerciseSetPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, ExerciseSet } from "@/types/academic"

const props = defineProps<{
  exercise_set: ExerciseSet & { course: Course }
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  {
    title: props.exercise_set.course.name,
    href: coursePath(props.exercise_set.course.id),
  },
  {
    title: t("exercises.title"),
    href: courseExerciseSetsPath(props.exercise_set.course.id),
  },
  { title: t("exercises.edit"), href: "#" },
]

const form = useForm({
  title: props.exercise_set.title,
  week_number: props.exercise_set.week_number,
  content: props.exercise_set.content,
  published: props.exercise_set.published,
})

function submit() {
  form
    .transform((data) => ({ exercise_set: data }))
    .patch(exerciseSetPath(props.exercise_set.id))
}
</script>

<template>
  <Head :title="t('exercises.edit')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="mx-auto w-full max-w-4xl p-4 md:p-6">
      <Card>
        <CardHeader>
          <CardTitle>{{ t("exercises.edit") }}</CardTitle>
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
              <Link :href="exerciseSetPath(exercise_set.id)">
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
