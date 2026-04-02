<script setup lang="ts">
import { Head, Link } from "@inertiajs/vue3"
import { BookOpen, Plus } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  exerciseSetPath,
  newCourseExerciseSetPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, ExerciseSet } from "@/types/academic"

const props = defineProps<{
  course: Course
  exercise_sets: ExerciseSet[]
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: props.course.name, href: coursePath(props.course.id) },
  { title: t("exercises.title"), href: "#" },
]
</script>

<template>
  <Head :title="t('exercises.title')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t("exercises.title") }} - {{ course.name }}
        </h1>
        <Button v-if="can.manage_exercises" as-child size="sm">
          <Link :href="newCourseExerciseSetPath(course.id)">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("exercises.new") }}
          </Link>
        </Button>
      </div>

      <div
        v-if="exercise_sets.length === 0"
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <BookOpen class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("exercises.no_exercises") }}</p>
      </div>

      <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Card v-for="exerciseSet in exercise_sets" :key="exerciseSet.id">
          <CardHeader>
            <div class="flex items-start justify-between gap-2">
              <CardTitle class="text-lg">
                <Link
                  :href="exerciseSetPath(exerciseSet.id)"
                  class="hover:underline"
                >
                  {{ exerciseSet.title }}
                </Link>
              </CardTitle>
              <Badge
                v-if="can.manage_exercises"
                :variant="exerciseSet.published ? 'default' : 'secondary'"
              >
                {{
                  exerciseSet.published
                    ? t("exercises.published")
                    : t("exercises.draft")
                }}
              </Badge>
            </div>
          </CardHeader>
          <CardContent>
            <p class="text-muted-foreground text-sm">
              {{ t("exercises.week_number") }}: {{ exerciseSet.week_number }}
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  </AppLayout>
</template>
