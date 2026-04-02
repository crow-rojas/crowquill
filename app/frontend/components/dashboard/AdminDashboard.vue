<script setup lang="ts">
import { Link } from "@inertiajs/vue3"
import { BookOpen, GraduationCap, Users } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { tutoringSessionPath } from "@/routes"
import type { AdminDashboardProps, DashboardSession } from "@/types/dashboard"

const props = defineProps<AdminDashboardProps>()
const { t } = useI18n()

function formatDate(date: string): string {
  return new Date(date).toLocaleDateString()
}

function sessionStatusClass(session: DashboardSession): string {
  switch (session.status) {
    case "completed":
      return "text-green-600"
    case "cancelled":
      return "text-red-600"
    default:
      return "text-blue-600"
  }
}
</script>

<template>
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">
          {{ t("dashboard.active_period") }}
        </CardTitle>
        <BookOpen class="text-muted-foreground h-4 w-4" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">
          {{ props.active_period?.name ?? t("dashboard.no_active_period") }}
        </div>
      </CardContent>
    </Card>

    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">
          {{ t("dashboard.total_students") }}
        </CardTitle>
        <GraduationCap class="text-muted-foreground h-4 w-4" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">{{ props.total_students }}</div>
      </CardContent>
    </Card>

    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">
          {{ t("dashboard.total_tutors") }}
        </CardTitle>
        <Users class="text-muted-foreground h-4 w-4" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">{{ props.total_tutors }}</div>
      </CardContent>
    </Card>

    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">
          {{ t("dashboard.active_sections") }}
        </CardTitle>
        <BookOpen class="text-muted-foreground h-4 w-4" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">{{ props.active_sections }}</div>
      </CardContent>
    </Card>
  </div>

  <Card class="mt-4">
    <CardHeader>
      <CardTitle>{{ t("dashboard.attendance_overview") }}</CardTitle>
      <CardDescription>
        {{ t("dashboard.upcoming_sessions") }}
      </CardDescription>
    </CardHeader>
    <CardContent>
      <div
        v-if="props.recent_sessions.length === 0"
        class="text-muted-foreground py-4 text-center text-sm"
      >
        {{ t("dashboard.no_upcoming") }}
      </div>
      <div v-else class="space-y-3">
        <Link
          v-for="session in props.recent_sessions"
          :key="session.id"
          :href="tutoringSessionPath(session.id)"
          class="hover:bg-muted flex items-center justify-between rounded-lg border p-3 transition-colors"
        >
          <div>
            <p class="font-medium">{{ session.course.name }}</p>
            <p class="text-muted-foreground text-sm">
              {{ session.section.name }} &middot; {{ formatDate(session.date) }}
            </p>
          </div>
          <div class="text-right">
            <span
              :class="sessionStatusClass(session)"
              class="text-sm font-medium capitalize"
            >
              {{ session.status }}
            </span>
            <p
              v-if="session.attendance_count !== undefined"
              class="text-muted-foreground text-xs"
            >
              {{ session.attendance_count }}
              {{ t("dashboard.attendance_overview").toLowerCase() }}
            </p>
          </div>
        </Link>
      </div>
    </CardContent>
  </Card>
</template>
