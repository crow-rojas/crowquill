<script setup lang="ts">
import { Link } from "@inertiajs/vue3"
import { CalendarDays } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { tutoringSessionPath } from "@/routes"
import type { DashboardSession } from "@/types/dashboard"

defineProps<{
  session: DashboardSession | null
}>()

const { t } = useI18n()

function formatDate(date: string): string {
  return new Date(date).toLocaleDateString()
}
</script>

<template>
  <Card v-if="session" class="border-primary/30 bg-primary/5">
    <CardHeader
      class="flex flex-row items-center justify-between space-y-0 pb-2"
    >
      <CardTitle class="flex items-center gap-2">
        <CalendarDays class="h-5 w-5" />
        {{ t("dashboard.next_session") }}
      </CardTitle>
    </CardHeader>
    <CardContent>
      <div class="flex items-center justify-between">
        <div>
          <p class="text-lg font-semibold">{{ session.course.name }}</p>
          <p class="text-muted-foreground text-sm">
            {{ session.section.name }} &middot; {{ formatDate(session.date) }}
          </p>
        </div>
        <Button as-child>
          <Link :href="tutoringSessionPath(session.id)">
            {{ t("dashboard.go_to_session") }}
          </Link>
        </Button>
      </div>
    </CardContent>
  </Card>

  <Card v-else class="bg-muted/50">
    <CardContent class="flex items-center gap-3 py-6">
      <CalendarDays class="text-muted-foreground h-5 w-5 shrink-0" />
      <p class="text-muted-foreground text-sm">
        {{ t("dashboard.no_upcoming_sessions") }}
      </p>
    </CardContent>
  </Card>
</template>
