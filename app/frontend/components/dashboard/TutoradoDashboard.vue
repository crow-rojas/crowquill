<script setup lang="ts">
import { Link } from "@inertiajs/vue3"
import { BookOpen, Bot, Calendar } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import NextSessionCard from "@/components/dashboard/NextSessionCard.vue"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { exerciseSetPath, sectionPath, tutoringSessionPath } from "@/routes"
import type { TutoradoDashboardProps } from "@/types/dashboard"

const props = defineProps<TutoradoDashboardProps>()
const { t } = useI18n()

function formatDate(date: string): string {
  return new Date(date).toLocaleDateString()
}
</script>

<template>
  <NextSessionCard :session="props.next_session" />

  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
    <Card>
      <CardHeader>
        <CardTitle>{{ t("dashboard.my_sections") }}</CardTitle>
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
            class="hover:bg-muted flex items-center gap-3 rounded-lg border p-3 transition-colors"
          >
            <Calendar class="text-muted-foreground h-5 w-5 shrink-0" />
            <div>
              <p class="font-medium">{{ section.name }}</p>
              <p class="text-muted-foreground text-sm">
                {{ section.course.name }}
              </p>
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
            class="hover:bg-muted flex items-center gap-3 rounded-lg border p-3 transition-colors"
          >
            <Calendar class="text-muted-foreground h-5 w-5 shrink-0" />
            <div>
              <p class="font-medium">{{ session.course.name }}</p>
              <p class="text-muted-foreground text-sm">
                {{ session.section.name }} &middot;
                {{ formatDate(session.date) }}
              </p>
            </div>
          </Link>
        </div>
      </CardContent>
    </Card>

    <Card>
      <CardHeader>
        <CardTitle>{{ t("dashboard.recent_exercises") }}</CardTitle>
      </CardHeader>
      <CardContent>
        <div
          v-if="props.recent_exercises.length === 0"
          class="text-muted-foreground py-4 text-center text-sm"
        >
          {{ t("dashboard.no_exercises") }}
        </div>
        <div v-else class="space-y-3">
          <Link
            v-for="exercise in props.recent_exercises"
            :key="exercise.id"
            :href="exerciseSetPath(exercise.id)"
            class="hover:bg-muted flex items-center gap-3 rounded-lg border p-3 transition-colors"
          >
            <BookOpen class="text-muted-foreground h-5 w-5 shrink-0" />
            <div>
              <p class="font-medium">{{ exercise.title }}</p>
              <p class="text-muted-foreground text-sm">
                {{ t("dashboard.week") }} {{ exercise.week_number }}
              </p>
            </div>
          </Link>
        </div>
      </CardContent>
    </Card>
  </div>

  <Card class="mt-4">
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Bot class="h-5 w-5" />
        {{ t("dashboard.ai_chat") }}
      </CardTitle>
      <CardDescription>{{
        t("dashboard.ai_chat_description")
      }}</CardDescription>
    </CardHeader>
    <CardContent>
      <p class="text-muted-foreground text-sm">
        {{ t("dashboard.ai_chat_description") }}
      </p>
    </CardContent>
  </Card>
</template>
