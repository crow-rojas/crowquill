<script setup lang="ts">
import { Link } from "@inertiajs/vue3"
import { ClipboardCheck, Users } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { sectionPath, tutoringSessionPath } from "@/routes"
import type { TutorDashboardProps } from "@/types/dashboard"

const props = defineProps<TutorDashboardProps>()
const { t } = useI18n()

function formatDate(date: string): string {
  return new Date(date).toLocaleDateString()
}
</script>

<template>
  <div class="grid gap-4 md:grid-cols-2">
    <Card>
      <CardHeader>
        <CardTitle>{{ t("dashboard.my_sections") }}</CardTitle>
        <CardDescription>
          {{ t("dashboard.enrolled_students") }}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div
          v-if="props.my_sections.length === 0"
          class="text-muted-foreground py-4 text-center text-sm"
        >
          {{ t("dashboard.no_sections") }}
        </div>
        <div v-else class="space-y-3">
          <Link
            v-for="section in props.my_sections"
            :key="section.id"
            :href="sectionPath(section.id)"
            class="hover:bg-muted flex items-center justify-between rounded-lg border p-3 transition-colors"
          >
            <div>
              <p class="font-medium">{{ section.name }}</p>
              <p class="text-muted-foreground text-sm">
                {{ section.course.name }}
              </p>
            </div>
            <div class="flex items-center gap-1 text-sm">
              <Users class="h-4 w-4" />
              <span>{{ section.enrollments_count ?? 0 }}</span>
              <span v-if="section.max_students" class="text-muted-foreground">
                / {{ section.max_students }}
              </span>
            </div>
          </Link>
        </div>
      </CardContent>
    </Card>

    <Card>
      <CardHeader>
        <CardTitle>{{ t("dashboard.upcoming_sessions") }}</CardTitle>
      </CardHeader>
      <CardContent>
        <div
          v-if="props.upcoming_sessions.length === 0"
          class="text-muted-foreground py-4 text-center text-sm"
        >
          {{ t("dashboard.no_upcoming") }}
        </div>
        <div v-else class="space-y-3">
          <Link
            v-for="session in props.upcoming_sessions"
            :key="session.id"
            :href="tutoringSessionPath(session.id)"
            class="hover:bg-muted flex items-center justify-between rounded-lg border p-3 transition-colors"
          >
            <div>
              <p class="font-medium">{{ session.course.name }}</p>
              <p class="text-muted-foreground text-sm">
                {{ session.section.name }} &middot;
                {{ formatDate(session.date) }}
              </p>
            </div>
            <div class="flex items-center gap-2">
              <ClipboardCheck class="text-muted-foreground h-4 w-4" />
              <span class="text-sm">{{ t("dashboard.take_attendance") }}</span>
            </div>
          </Link>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
