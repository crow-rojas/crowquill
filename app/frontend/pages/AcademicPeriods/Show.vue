<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { BookOpen, Plus } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodPath,
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  editAcademicPeriodPath,
  newAcademicPeriodCoursePath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { AcademicPeriod, Course } from "@/types/academic"

const props = defineProps<{
  academic_period: AcademicPeriod & { courses: Course[] }
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  {
    title: props.academic_period.name,
    href: academicPeriodPath(props.academic_period.id),
  },
]

function statusVariant(
  status: AcademicPeriod["status"],
): "default" | "secondary" | "outline" {
  switch (status) {
    case "active":
      return "default"
    case "draft":
      return "secondary"
    case "archived":
      return "outline"
  }
}

function deletePeriod() {
  if (confirm(t("academic_periods.confirm_delete"))) {
    router.delete(academicPeriodPath(props.academic_period.id))
  }
}
</script>

<template>
  <Head :title="academic_period.name" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <div class="flex items-center gap-3">
          <h1 class="text-2xl font-semibold tracking-tight">
            {{ academic_period.name }}
          </h1>
          <Badge :variant="statusVariant(academic_period.status)">
            {{ t(`academic_periods.statuses.${academic_period.status}`) }}
          </Badge>
        </div>
        <div v-if="can.manage_academic_periods" class="flex gap-2">
          <Button variant="outline" size="sm" as-child>
            <Link :href="editAcademicPeriodPath(academic_period.id)">
              {{ t("common.edit") }}
            </Link>
          </Button>
          <Button
            variant="outline"
            size="sm"
            class="text-destructive"
            @click="deletePeriod"
          >
            {{ t("common.delete") }}
          </Button>
        </div>
      </div>

      <div class="text-muted-foreground text-sm">
        {{ academic_period.start_date }} &mdash; {{ academic_period.end_date }}
      </div>

      <div class="flex items-center justify-between">
        <h2 class="text-xl font-semibold">{{ t("courses.title") }}</h2>
        <Button v-if="can.manage_courses" as-child size="sm">
          <Link :href="newAcademicPeriodCoursePath(academic_period.id)">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("courses.new") }}
          </Link>
        </Button>
      </div>

      <div
        v-if="academic_period.courses.length === 0"
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <BookOpen class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("courses.no_courses") }}</p>
      </div>

      <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Card v-for="course in academic_period.courses" :key="course.id">
          <CardHeader>
            <CardTitle class="text-lg">
              <Link :href="coursePath(course.id)" class="hover:underline">
                {{ course.name }}
              </Link>
            </CardTitle>
            <CardDescription v-if="course.description">
              {{ course.description }}
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    </div>
  </AppLayout>
</template>
