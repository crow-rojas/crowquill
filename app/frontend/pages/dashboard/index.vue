<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
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

const hasRole =
  props.role === "admin" || props.role === "tutor" || props.role === "tutorado"
</script>

<template>
  <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div
      class="flex h-full flex-1 flex-col gap-4 overflow-x-auto rounded-xl p-4"
    >
      <h1 class="text-2xl font-bold">{{ t("dashboard.title") }}</h1>

      <AdminDashboard v-if="props.role === 'admin'" v-bind="props" />
      <TutorDashboard v-else-if="props.role === 'tutor'" v-bind="props" />
      <TutoradoDashboard v-else-if="props.role === 'tutorado'" v-bind="props" />

      <div v-if="!hasRole" class="text-muted-foreground py-8 text-center">
        {{ t("dashboard.welcome") }}
      </div>
    </div>
  </AppLayout>
</template>
