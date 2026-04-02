<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { CalendarDays, Plus } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodPath,
  academicPeriodsPath,
  dashboardPath,
  editAcademicPeriodPath,
  newAcademicPeriodPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { AcademicPeriod } from "@/types/academic"

const props = defineProps<{
  academic_periods: AcademicPeriod[]
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
]

function statusVariant(
  status: AcademicPeriod["status"],
): "default" | "secondary" | "outline" {
  switch (status) {
    case "active":
      return "default"
    case "draft":
      return "secondary"
    case "archived":
      return "outline"
  }
}

function deletePeriod(period: AcademicPeriod) {
  if (confirm(t("academic_periods.confirm_delete"))) {
    router.delete(academicPeriodPath(period.id))
  }
}
</script>

<template>
  <Head :title="t('academic_periods.title')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t("academic_periods.title") }}
        </h1>
        <Button v-if="can.manage_academic_periods" as-child size="sm">
          <Link :href="newAcademicPeriodPath()">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("academic_periods.new") }}
          </Link>
        </Button>
      </div>

      <div
        v-if="props.academic_periods.length === 0"
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <CalendarDays class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("academic_periods.no_periods") }}</p>
      </div>

      <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Card v-for="period in props.academic_periods" :key="period.id">
          <CardHeader>
            <div class="flex items-start justify-between gap-2">
              <div>
                <CardTitle class="text-lg">
                  <Link
                    :href="academicPeriodPath(period.id)"
                    class="hover:underline"
                  >
                    {{ period.name }}
                  </Link>
                </CardTitle>
                <CardDescription>
                  {{ period.start_date }} &mdash; {{ period.end_date }}
                </CardDescription>
              </div>
              <Badge :variant="statusVariant(period.status)">
                {{ t(`academic_periods.statuses.${period.status}`) }}
              </Badge>
            </div>
          </CardHeader>
          <CardContent v-if="can.manage_academic_periods">
            <div class="flex gap-2">
              <Button variant="outline" size="sm" as-child>
                <Link :href="editAcademicPeriodPath(period.id)">
                  {{ t("common.edit") }}
                </Link>
              </Button>
              <Button
                variant="outline"
                size="sm"
                class="text-destructive"
                @click="deletePeriod(period)"
              >
                {{ t("common.delete") }}
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </AppLayout>
</template>
