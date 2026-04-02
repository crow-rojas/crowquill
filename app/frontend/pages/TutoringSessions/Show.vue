<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { Calendar } from "lucide-vue-next"
import { computed } from "vue"
import { useI18n } from "vue-i18n"

import AttendanceGrid from "@/components/AttendanceGrid.vue"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  editTutoringSessionPath,
  sectionPath,
  sectionTutoringSessionsPath,
  tutoringSessionPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type {
  Attendance,
  Course,
  Enrollment,
  Section,
  TutoringSession,
} from "@/types/academic"

const props = defineProps<{
  tutoring_session: TutoringSession & {
    section: Section & {
      course: Course
      tutor?: { id: number; name: string; email: string }
    }
  }
  enrollments: Enrollment[]
  attendances: Attendance[]
  can_manage_session: boolean
  can_take_attendance: boolean
}>()

const { t } = useI18n()
const { can } = usePermissions()
const ownAttendance = computed(() => props.attendances[0] ?? null)

const section = props.tutoring_session.section
const course = section.course!

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  {
    title: course.name,
    href: coursePath(course.id),
  },
  {
    title: section.name,
    href: sectionPath(section.id),
  },
  {
    title: t("sessions.title"),
    href: sectionTutoringSessionsPath(section.id),
  },
  {
    title: props.tutoring_session.date,
    href: tutoringSessionPath(props.tutoring_session.id),
  },
]

function statusVariant(
  status: string,
): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case "completed":
      return "default"
    case "cancelled":
      return "destructive"
    default:
      return "secondary"
  }
}

function deleteSession() {
  if (confirm(t("sessions.confirm_delete"))) {
    router.delete(tutoringSessionPath(props.tutoring_session.id))
  }
}
</script>

<template>
  <Head :title="`${section.name} — ${tutoring_session.date}`" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <div>
          <h1 class="text-2xl font-semibold tracking-tight">
            <Calendar class="mr-2 inline h-5 w-5" />
            {{ section.name }} — {{ tutoring_session.date }}
          </h1>
          <Badge :variant="statusVariant(tutoring_session.status)" class="mt-2">
            {{ t(`sessions.statuses.${tutoring_session.status}`) }}
          </Badge>
        </div>
        <div
          v-if="can_manage_session || can.manage_sections"
          class="flex gap-2"
        >
          <Button
            v-if="can_manage_session"
            variant="outline"
            size="sm"
            as-child
          >
            <Link :href="editTutoringSessionPath(tutoring_session.id)">
              {{ t("common.edit") }}
            </Link>
          </Button>
          <Button
            v-if="can.manage_sections"
            variant="outline"
            size="sm"
            class="text-destructive"
            @click="deleteSession"
          >
            {{ t("common.delete") }}
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{{ t("attendance.title") }}</CardTitle>
        </CardHeader>
        <CardContent>
          <AttendanceGrid
            v-if="can_take_attendance"
            :tutoring-session-id="tutoring_session.id"
            :enrollments="enrollments"
            :attendances="attendances"
          />

          <div v-else class="rounded-lg border p-4">
            <p class="text-muted-foreground text-sm">
              {{ t("attendance.my_status") }}
            </p>
            <p class="mt-2 text-base font-medium">
              {{
                ownAttendance
                  ? t(`attendance.statuses.${ownAttendance.status}`)
                  : t("attendance.not_recorded")
              }}
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  </AppLayout>
</template>
