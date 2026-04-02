<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { BookOpen, Plus, Users } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
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
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  editCoursePath,
  exerciseSetPath,
  newCourseExerciseSetPath,
  newCourseSectionPath,
  sectionPath,
  sectionTutoringSessionsPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, ExerciseSet, Section } from "@/types/academic"

const props = defineProps<{
  course: Course & { sections: Section[] }
  exercise_sets: ExerciseSet[]
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: props.course.name, href: coursePath(props.course.id) },
]

function deleteCourse() {
  if (confirm(t("courses.confirm_delete"))) {
    router.delete(coursePath(props.course.id))
  }
}
</script>

<template>
  <Head :title="course.name" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <!-- Course header -->
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <div>
          <h1 class="text-2xl font-semibold tracking-tight">
            {{ course.name }}
          </h1>
          <p
            v-if="course.description"
            class="text-muted-foreground mt-1 text-sm"
          >
            {{ course.description }}
          </p>
        </div>
        <div v-if="can.manage_courses" class="flex gap-2">
          <Button variant="outline" size="sm" as-child>
            <Link :href="editCoursePath(course.id)">
              {{ t("common.edit") }}
            </Link>
          </Button>
          <Button
            variant="outline"
            size="sm"
            class="text-destructive"
            @click="deleteCourse"
          >
            {{ t("common.delete") }}
          </Button>
        </div>
      </div>

      <!-- Sections -->
      <div class="flex items-center justify-between">
        <h2 class="text-xl font-semibold">{{ t("sections.title") }}</h2>
        <Button v-if="can.manage_sections" as-child size="sm">
          <Link :href="newCourseSectionPath(course.id)">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("sections.new") }}
          </Link>
        </Button>
      </div>

      <div v-if="course.sections.length > 0" class="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>{{ t("sections.name") }}</TableHead>
              <TableHead>{{ t("sections.tutor") }}</TableHead>
              <TableHead class="text-right">{{
                t("sections.max_students")
              }}</TableHead>
              <TableHead class="text-right">{{
                t("common.actions")
              }}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="section in course.sections" :key="section.id">
              <TableCell class="font-medium">
                <Link :href="sectionPath(section.id)" class="hover:underline">
                  {{ section.name }}
                </Link>
              </TableCell>
              <TableCell>{{ section.tutor?.name || "-" }}</TableCell>
              <TableCell class="text-right">{{
                section.max_students
              }}</TableCell>
              <TableCell class="text-right">
                <div class="flex flex-wrap justify-end gap-2">
                  <Button variant="outline" size="sm" as-child>
                    <Link :href="sectionPath(section.id)">
                      {{ t("common.view") }}
                    </Link>
                  </Button>
                  <Button
                    v-if="section.can_view_sessions"
                    variant="outline"
                    size="sm"
                    as-child
                  >
                    <Link :href="sectionTutoringSessionsPath(section.id)">
                      {{ t("sections.sessions_action") }}
                    </Link>
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>

      <div
        v-else
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <Users class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("sections.no_sections") }}</p>
      </div>

      <!-- Exercises -->
      <div class="flex items-center justify-between">
        <h2 class="text-xl font-semibold">{{ t("exercises.title") }}</h2>
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
        <Card v-for="exercise in exercise_sets" :key="exercise.id">
          <CardHeader>
            <div class="flex items-center justify-between">
              <CardTitle class="text-lg">
                <Link
                  :href="exerciseSetPath(exercise.id)"
                  class="hover:underline"
                >
                  {{ exercise.title }}
                </Link>
              </CardTitle>
              <Badge v-if="!exercise.published" variant="secondary">
                {{ t("exercises.draft") }}
              </Badge>
            </div>
            <CardDescription>
              {{ t("exercises.week_number") }}: {{ exercise.week_number }}
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    </div>
  </AppLayout>
</template>
