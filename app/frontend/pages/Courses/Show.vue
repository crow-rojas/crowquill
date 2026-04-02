<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { Plus, Users } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodsPath,
  coursePath,
  editCoursePath,
  newCourseSectionPath,
  sectionPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, Section } from "@/types/academic"

const props = defineProps<{
  course: Course & { sections: Section[] }
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: "/dashboard" },
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

      <div class="flex items-center justify-between">
        <h2 class="text-xl font-semibold">{{ t("sections.title") }}</h2>
        <Button v-if="can.manage_sections" as-child size="sm">
          <Link :href="newCourseSectionPath(course.id)">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("sections.new") }}
          </Link>
        </Button>
      </div>

      <div
        v-if="course.sections.length === 0"
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <Users class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("sections.no_sections") }}</p>
      </div>

      <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Card v-for="section in course.sections" :key="section.id">
          <CardHeader>
            <CardTitle class="text-lg">
              <Link :href="sectionPath(section.id)" class="hover:underline">
                {{ section.name }}
              </Link>
            </CardTitle>
            <CardDescription v-if="section.tutor">
              {{ t("sections.tutor") }}: {{ section.tutor.name }}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div class="text-muted-foreground flex items-center gap-1 text-sm">
              <Users class="h-4 w-4" />
              <span
                >{{ t("sections.max_students") }}:
                {{ section.max_students }}</span
              >
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </AppLayout>
</template>
