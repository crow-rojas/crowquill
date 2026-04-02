<script setup lang="ts">
import { Head, router } from "@inertiajs/vue3"
import { Users } from "lucide-vue-next"
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
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  enrollmentPath,
  sectionEnrollmentsPath,
  sectionPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, Enrollment, Section } from "@/types/academic"

const props = defineProps<{
  section: Section & { course: Course }
  enrollments: Enrollment[]
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  {
    title: props.section.course.name,
    href: coursePath(props.section.course.id),
  },
  {
    title: props.section.name,
    href: sectionPath(props.section.id),
  },
  {
    title: t("enrollment.title"),
    href: sectionEnrollmentsPath(props.section.id),
  },
]

function withdrawEnrollment(enrollment: Enrollment) {
  router.patch(enrollmentPath(enrollment.id))
}

function deleteEnrollment(enrollment: Enrollment) {
  if (confirm(t("enrollment.confirm_delete"))) {
    router.delete(enrollmentPath(enrollment.id))
  }
}
</script>

<template>
  <Head :title="`${section.name} — ${t('enrollment.title')}`" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <h1 class="text-2xl font-semibold tracking-tight">
          <Users class="mr-2 inline h-5 w-5" />
          {{ t("enrollment.title") }} — {{ section.name }}
        </h1>
        <div class="text-muted-foreground text-sm">
          {{ enrollments.filter((e) => e.status === "active").length }} /
          {{ section.max_students }}
          {{ t("sections.enrolled_students") }}
        </div>
      </div>

      <div
        v-if="enrollments.length === 0"
        class="text-muted-foreground py-8 text-center"
      >
        {{ t("enrollment.no_enrollments") }}
      </div>

      <Table v-else>
        <TableHeader>
          <TableRow>
            <TableHead>{{ t("enrollment.student") }}</TableHead>
            <TableHead>{{ t("enrollment.status") }}</TableHead>
            <TableHead class="text-right">
              {{ t("common.actions") }}
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="enrollment in enrollments" :key="enrollment.id">
            <TableCell>
              <div>
                <p class="font-medium">{{ enrollment.user?.name }}</p>
                <p class="text-muted-foreground text-sm">
                  {{ enrollment.user?.email }}
                </p>
              </div>
            </TableCell>
            <TableCell>
              <Badge
                :variant="
                  enrollment.status === 'active' ? 'default' : 'secondary'
                "
              >
                {{ t(`enrollment.statuses.${enrollment.status}`) }}
              </Badge>
            </TableCell>
            <TableCell class="text-right">
              <div class="flex justify-end gap-2">
                <Button
                  v-if="enrollment.status === 'active'"
                  variant="outline"
                  size="sm"
                  @click="withdrawEnrollment(enrollment)"
                >
                  {{ t("enrollment.withdraw") }}
                </Button>
                <Button
                  v-if="can.manage_enrollments"
                  variant="outline"
                  size="sm"
                  class="text-destructive"
                  @click="deleteEnrollment(enrollment)"
                >
                  {{ t("common.delete") }}
                </Button>
              </div>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
  </AppLayout>
</template>
