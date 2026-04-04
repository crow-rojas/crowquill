<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { BookOpen, Plus } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

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
  courseSectionsPath,
  dashboardPath,
  editCoursePath,
  newAcademicPeriodCoursePath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { AcademicPeriod, Course } from "@/types/academic"

const props = defineProps<{
  academic_period: AcademicPeriod
  courses: Course[]
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  {
    title: t("nav.courses"),
    href: academicPeriodCoursesPath(props.academic_period.id),
  },
]

function deleteCourse(course: Course) {
  if (confirm(t("courses.confirm_delete"))) {
    router.delete(coursePath(course.id))
  }
}
</script>

<template>
  <Head :title="t('courses.title')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t("courses.title") }}
        </h1>
        <Button v-if="can.manage_courses" as-child size="sm">
          <Link :href="newAcademicPeriodCoursePath(academic_period.id)">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("courses.new") }}
          </Link>
        </Button>
      </div>

      <div
        v-if="courses.length === 0"
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <BookOpen class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("courses.no_courses") }}</p>
      </div>

      <div v-else class="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>{{ t("courses.name") }}</TableHead>
              <TableHead>{{ t("courses.description") }}</TableHead>
              <TableHead class="text-right">{{
                t("common.actions")
              }}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="course in courses" :key="course.id">
              <TableCell class="font-medium">
                <Link :href="coursePath(course.id)" class="hover:underline">
                  {{ course.name }}
                </Link>
              </TableCell>
              <TableCell>{{ course.description || "-" }}</TableCell>
              <TableCell class="text-right">
                <div class="flex flex-wrap justify-end gap-2">
                  <Button variant="outline" size="sm" as-child>
                    <Link :href="coursePath(course.id)">
                      {{ t("common.view") }}
                    </Link>
                  </Button>
                  <Button variant="outline" size="sm" as-child>
                    <Link :href="courseSectionsPath(course.id)">
                      {{ t("sections.title") }}
                    </Link>
                  </Button>
                  <Button
                    v-if="can.manage_courses"
                    variant="outline"
                    size="sm"
                    as-child
                  >
                    <Link :href="editCoursePath(course.id)">
                      {{ t("common.edit") }}
                    </Link>
                  </Button>
                  <Button
                    v-if="can.manage_courses"
                    variant="outline"
                    size="sm"
                    class="text-destructive"
                    @click="deleteCourse(course)"
                  >
                    {{ t("common.delete") }}
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </div>
  </AppLayout>
</template>
