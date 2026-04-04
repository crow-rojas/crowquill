<script setup lang="ts">
import { Head, Link } from "@inertiajs/vue3"
import { BookOpen, Plus } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodCoursesPath,
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
  {
    title: t("nav.courses"),
    href: academicPeriodCoursesPath(props.course.academic_period_id),
  },
  { title: props.course.name, href: coursePath(props.course.id) },
  { title: t("exercises.title"), href: coursePath(props.course.id) },
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

      <div v-else class="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>{{ t("exercises.name") }}</TableHead>
              <TableHead class="text-right">{{
                t("exercises.week_number")
              }}</TableHead>
              <TableHead class="text-right">{{
                t("common.actions")
              }}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow
              v-for="exerciseSet in exercise_sets"
              :key="exerciseSet.id"
            >
              <TableCell class="font-medium">
                <div class="flex flex-wrap items-center gap-2">
                  <Link
                    :href="exerciseSetPath(exerciseSet.id)"
                    class="hover:underline"
                  >
                    {{ exerciseSet.title }}
                  </Link>
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
              </TableCell>
              <TableCell class="text-right">{{
                exerciseSet.week_number
              }}</TableCell>
              <TableCell class="text-right">
                <Button variant="outline" size="sm" as-child>
                  <Link :href="exerciseSetPath(exerciseSet.id)">
                    {{ t("common.view") }}
                  </Link>
                </Button>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </div>
  </AppLayout>
</template>
