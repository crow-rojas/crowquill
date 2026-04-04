<script setup lang="ts">
import { BookOpen } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import MarkdownLatex from "@/components/MarkdownLatex.vue"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { ExerciseSet } from "@/types/academic"

defineProps<{
  exerciseSets: ExerciseSet[]
  matchType: "week" | "all"
  weekNumber?: number
}>()

const { t } = useI18n()
</script>

<template>
  <div class="space-y-4">
    <h2 class="text-xl font-semibold">
      {{
        matchType === "week" && weekNumber
          ? t("sessions.week_exercises", { week: weekNumber })
          : t("sessions.all_exercises")
      }}
    </h2>

    <div
      v-if="exerciseSets.length === 0"
      class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
    >
      <BookOpen class="mb-4 h-12 w-12 opacity-40" />
      <p>{{ t("sessions.no_exercises") }}</p>
    </div>

    <Card v-for="exercise in exerciseSets" :key="exercise.id">
      <CardHeader>
        <div class="flex items-center gap-2">
          <CardTitle>{{ exercise.title }}</CardTitle>
          <Badge variant="secondary">
            {{ t("exercises.week_number") }}: {{ exercise.week_number }}
          </Badge>
          <Badge v-if="!exercise.published" variant="outline">
            {{ t("exercises.draft") }}
          </Badge>
        </div>
      </CardHeader>
      <CardContent>
        <MarkdownLatex :content="exercise.content" />
      </CardContent>
    </Card>
  </div>
</template>
