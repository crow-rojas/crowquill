<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import MarkdownLatex from "@/components/MarkdownLatex.vue"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodsPath,
  courseExerciseSetsPath,
  coursePath,
  dashboardPath,
  editExerciseSetPath,
  exerciseSetPath,
  publishExerciseSetPath,
  unpublishExerciseSetPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, ExerciseSet } from "@/types/academic"

const props = defineProps<{
  exercise_set: ExerciseSet & { course: Course }
}>()

const { t } = useI18n()
const { can } = usePermissions()

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
  { title: props.exercise_set.title, href: "#" },
]

function deleteExerciseSet() {
  if (confirm(t("exercises.confirm_delete"))) {
    router.delete(exerciseSetPath(props.exercise_set.id))
  }
}

function togglePublish() {
  if (props.exercise_set.published) {
    router.patch(unpublishExerciseSetPath(props.exercise_set.id))
  } else {
    router.patch(publishExerciseSetPath(props.exercise_set.id))
  }
}
</script>

<template>
  <Head :title="exercise_set.title" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <div>
          <div class="flex items-center gap-2">
            <h1 class="text-2xl font-semibold tracking-tight">
              {{ exercise_set.title }}
            </h1>
            <Badge
              v-if="can.manage_exercises"
              :variant="exercise_set.published ? 'default' : 'secondary'"
            >
              {{
                exercise_set.published
                  ? t("exercises.published")
                  : t("exercises.draft")
              }}
            </Badge>
          </div>
          <p class="text-muted-foreground mt-1 text-sm">
            {{ t("exercises.week_number") }}: {{ exercise_set.week_number }}
          </p>
        </div>
        <div v-if="can.manage_exercises" class="flex gap-2">
          <Button variant="outline" size="sm" @click="togglePublish">
            {{
              exercise_set.published
                ? t("exercises.unpublish")
                : t("exercises.publish")
            }}
          </Button>
          <Button variant="outline" size="sm" as-child>
            <Link :href="editExerciseSetPath(exercise_set.id)">
              {{ t("common.edit") }}
            </Link>
          </Button>
          <Button
            variant="outline"
            size="sm"
            class="text-destructive"
            @click="deleteExerciseSet"
          >
            {{ t("common.delete") }}
          </Button>
        </div>
      </div>

      <div class="rounded-lg border p-6">
        <MarkdownLatex :content="exercise_set.content" />
      </div>
    </div>
  </AppLayout>
</template>
