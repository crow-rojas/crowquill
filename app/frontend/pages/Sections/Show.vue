<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { Calendar, Users } from "lucide-vue-next"
import { computed } from "vue"
import { useI18n } from "vue-i18n"

import CommitmentDialog from "@/components/CommitmentDialog.vue"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  editSectionPath,
  newSectionTutoringSessionPath,
  sectionEnrollmentsPath,
  sectionPath,
  sectionTutoringSessionsPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, Enrollment, Section } from "@/types/academic"

const props = defineProps<{
  section: Section & { course: Course }
  enrollments_count?: number
  current_enrollment?: Enrollment | null
  is_full?: boolean
  can_view_enrollments?: boolean
  can_view_sessions?: boolean
  can_create_session?: boolean
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
]

interface ScheduleRow {
  key: string
  day: string
  time: string
  room?: string
}

function readText(value: unknown): string | undefined {
  if (typeof value !== "string") {
    return undefined
  }

  const normalized = value.trim()
  return normalized.length > 0 ? normalized : undefined
}

function titleize(value: string): string {
  return value
    .replace(/_/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase())
}

function dayLabel(day: string): string {
  const normalized = day.trim().toLowerCase()
  const translated = t(`sections.days.${normalized}`)
  return translated === `sections.days.${normalized}`
    ? titleize(normalized)
    : translated
}

function formatTimeRange(start?: string, end?: string): string {
  if (start && end) {
    return `${start} - ${end}`
  }

  return start || end || t("sections.unspecified_time")
}

const scheduleRows = computed<ScheduleRow[]>(() => {
  if (!props.section.schedule || typeof props.section.schedule !== "object") {
    return []
  }

  const schedule = props.section.schedule as Record<string, unknown>
  const flatDay = readText(schedule.day)
  const flatStart = readText(schedule.start_time)
  const flatEnd = readText(schedule.end_time)
  const flatRoom = readText(schedule.room)

  if (flatDay || flatStart || flatEnd || flatRoom) {
    return [
      {
        key: "flat-schedule",
        day: flatDay ? dayLabel(flatDay) : t("sections.unspecified_day"),
        time: formatTimeRange(flatStart, flatEnd),
        room: flatRoom,
      },
    ]
  }

  return Object.entries(schedule).map(([day, details]) => {
    if (typeof details === "string") {
      return {
        key: day,
        day: dayLabel(day),
        time: details,
      }
    }

    if (details && typeof details === "object") {
      const detailRecord = details as Record<string, unknown>
      const start =
        readText(detailRecord.start) || readText(detailRecord.start_time)
      const end = readText(detailRecord.end) || readText(detailRecord.end_time)
      const room = readText(detailRecord.room)

      return {
        key: day,
        day: dayLabel(day),
        time: formatTimeRange(start, end),
        room,
      }
    }

    return {
      key: day,
      day: dayLabel(day),
      time: details == null ? t("sections.unspecified_time") : String(details),
    }
  })
})

function deleteSection() {
  if (confirm(t("sections.confirm_delete"))) {
    router.delete(sectionPath(props.section.id))
  }
}
</script>

<template>
  <Head :title="section.name" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ section.name }}
        </h1>
        <div v-if="can.manage_sections" class="flex gap-2">
          <Button variant="outline" size="sm" as-child>
            <Link :href="editSectionPath(section.id)">
              {{ t("common.edit") }}
            </Link>
          </Button>
          <Button
            variant="outline"
            size="sm"
            class="text-destructive"
            @click="deleteSection"
          >
            {{ t("common.delete") }}
          </Button>
        </div>
      </div>

      <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle class="flex items-center gap-2 text-base">
              <Users class="h-4 w-4" />
              {{ t("sections.tutor") }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p v-if="section.tutor">{{ section.tutor.name }}</p>
            <p v-else class="text-muted-foreground">-</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle class="flex items-center gap-2 text-base">
              <Users class="h-4 w-4" />
              {{ t("sections.max_students") }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p>{{ section.max_students }}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle class="flex items-center gap-2 text-base">
              <Calendar class="h-4 w-4" />
              {{ t("sections.schedule") }}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div v-if="scheduleRows.length > 0" class="space-y-2 text-sm">
              <div
                v-for="entry in scheduleRows"
                :key="entry.key"
                class="space-y-1 rounded-md border p-3"
              >
                <p class="font-medium">{{ entry.day }}</p>
                <p class="text-muted-foreground">
                  {{ t("sections.time_label") }}: {{ entry.time }}
                </p>
                <p v-if="entry.room" class="text-muted-foreground">
                  {{ t("sections.room_label") }}: {{ entry.room }}
                </p>
              </div>
            </div>
            <p v-else class="text-muted-foreground text-sm">
              {{ t("sections.no_schedule") }}
            </p>
          </CardContent>
        </Card>
      </div>

      <div
        v-if="can_view_sessions || can_create_session"
        class="flex flex-wrap items-center gap-2"
      >
        <Button v-if="can_view_sessions" variant="outline" size="sm" as-child>
          <Link :href="sectionTutoringSessionsPath(section.id)">
            {{ t("sessions.title") }}
          </Link>
        </Button>
        <Button v-if="can_create_session" size="sm" as-child>
          <Link :href="newSectionTutoringSessionPath(section.id)">
            {{ t("sessions.new") }}
          </Link>
        </Button>
      </div>

      <div class="flex flex-col gap-4">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold">
            {{ t("enrollment.title") }}
            <span class="text-muted-foreground text-sm font-normal">
              ({{ enrollments_count ?? 0 }} / {{ section.max_students }})
            </span>
          </h2>
          <div class="flex gap-2">
            <Button
              v-if="can_view_enrollments"
              variant="outline"
              size="sm"
              as-child
            >
              <Link :href="sectionEnrollmentsPath(section.id)">
                {{ t("enrollment.title") }}
              </Link>
            </Button>
            <CommitmentDialog
              v-if="!current_enrollment"
              :section-id="section.id"
              :disabled="is_full"
            />
          </div>
        </div>
        <p v-if="is_full" class="text-muted-foreground text-sm">
          {{ t("enrollment.full_section") }}
        </p>
        <p v-if="current_enrollment" class="text-sm text-green-600">
          {{ t("enrollment.committed") }}
        </p>
      </div>
    </div>
  </AppLayout>
</template>
