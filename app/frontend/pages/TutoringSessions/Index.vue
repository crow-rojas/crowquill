<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { Calendar, Plus } from "lucide-vue-next"
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
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodCoursesPath,
  coursePath,
  dashboardPath,
  newSectionTutoringSessionPath,
  sectionPath,
  sectionTutoringSessionsPath,
  tutoringSessionPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, Section, TutoringSession } from "@/types/academic"

const props = defineProps<{
  section: Section & { course: Course }
  tutoring_sessions: TutoringSession[]
  can_create_session: boolean
  can_delete_session: boolean
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  {
    title: t("nav.courses"),
    href: academicPeriodCoursesPath(props.section.course.academic_period_id),
  },
  {
    title: props.section.course.name,
    href: coursePath(props.section.course.id),
  },
  {
    title: props.section.name,
    href: sectionPath(props.section.id),
  },
  {
    title: t("sessions.title"),
    href: sectionTutoringSessionsPath(props.section.id),
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

function deleteSession(session: TutoringSession) {
  if (confirm(t("sessions.confirm_delete"))) {
    router.delete(tutoringSessionPath(session.id))
  }
}
</script>

<template>
  <Head :title="`${section.name} — ${t('sessions.title')}`" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <h1 class="text-2xl font-semibold tracking-tight">
          <Calendar class="mr-2 inline h-5 w-5" />
          {{ t("sessions.title") }} — {{ section.name }}
        </h1>
        <Button v-if="can_create_session" size="sm" as-child>
          <Link :href="newSectionTutoringSessionPath(section.id)">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("sessions.new") }}
          </Link>
        </Button>
      </div>

      <div
        v-if="tutoring_sessions.length === 0"
        class="text-muted-foreground py-8 text-center"
      >
        {{ t("sessions.no_sessions") }}
      </div>

      <Table v-else>
        <TableHeader>
          <TableRow>
            <TableHead>{{ t("sessions.date") }}</TableHead>
            <TableHead>{{ t("sessions.status") }}</TableHead>
            <TableHead class="text-right">
              {{ t("common.actions") }}
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="session in tutoring_sessions" :key="session.id">
            <TableCell>
              <Link
                :href="tutoringSessionPath(session.id)"
                class="font-medium hover:underline"
              >
                {{ session.date }}
              </Link>
            </TableCell>
            <TableCell>
              <Badge :variant="statusVariant(session.status)">
                {{ t(`sessions.statuses.${session.status}`) }}
              </Badge>
            </TableCell>
            <TableCell class="text-right">
              <div class="flex justify-end gap-2">
                <Button variant="outline" size="sm" as-child>
                  <Link :href="tutoringSessionPath(session.id)">
                    {{ t("common.view") }}
                  </Link>
                </Button>
                <Button
                  v-if="can_delete_session"
                  variant="outline"
                  size="sm"
                  class="text-destructive"
                  @click="deleteSession(session)"
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
