<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
import { computed } from "vue"
import { useI18n } from "vue-i18n"

import AdminDashboard from "@/components/dashboard/AdminDashboard.vue"
import TutorDashboard from "@/components/dashboard/TutorDashboard.vue"
import TutoradoDashboard from "@/components/dashboard/TutoradoDashboard.vue"
import AppLayout from "@/layouts/AppLayout.vue"
import { dashboardPath } from "@/routes"
import { type BreadcrumbItem } from "@/types"
import type { DashboardProps } from "@/types/dashboard"

const props = defineProps<DashboardProps>()
const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  {
    title: t("nav.dashboard"),
    href: dashboardPath(),
  },
]

const dashboardComponent = computed(() => {
  switch (props.role) {
    case "admin":
      return AdminDashboard
    case "tutor":
      return TutorDashboard
    case "tutorado":
      return TutoradoDashboard
    default:
      return null
  }
})
</script>

<template>
  <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div
      class="flex h-full flex-1 flex-col gap-4 overflow-x-auto rounded-xl p-4"
    >
      <h1 class="text-2xl font-bold">{{ t("dashboard.title") }}</h1>

      <component
        :is="dashboardComponent"
        v-if="dashboardComponent"
        v-bind="props"
      />

      <div v-else class="text-muted-foreground py-8 text-center">
        {{ t("dashboard.welcome") }}
      </div>
    </div>
  </AppLayout>
</template>
