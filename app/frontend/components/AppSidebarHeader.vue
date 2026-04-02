<script setup lang="ts">
import { Link, usePage } from "@inertiajs/vue3"
import { CalendarDays, Check } from "lucide-vue-next"
import { computed } from "vue"
import { useI18n } from "vue-i18n"

import Breadcrumbs from "@/components/Breadcrumbs.vue"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { SidebarTrigger } from "@/components/ui/sidebar"
import { academicPeriodPath, academicPeriodsPath } from "@/routes"
import type { Auth, BreadcrumbItemType } from "@/types"

const { t } = useI18n()
const page = usePage()

const auth = computed(() => page.props.auth as Partial<Auth> | undefined)
const academicPeriodContext = computed(() => {
  return auth.value?.academic_period_context ?? { active: null, available: [] }
})
const activeAcademicPeriod = computed(() => academicPeriodContext.value.active)
const availableAcademicPeriods = computed(
  () => academicPeriodContext.value.available,
)
const hasAcademicPeriods = computed(
  () => availableAcademicPeriods.value.length > 0,
)
const activePeriodId = computed(() => activeAcademicPeriod.value?.id ?? null)
const activePeriodLabel = computed(() => {
  return activeAcademicPeriod.value?.name || t("nav.no_active_period")
})

withDefaults(
  defineProps<{
    breadcrumbs?: BreadcrumbItemType[]
  }>(),
  {
    breadcrumbs: () => [],
  },
)
</script>

<template>
  <header
    class="border-sidebar-border/70 flex h-16 shrink-0 items-center gap-2 border-b px-6 transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-12 md:px-4"
  >
    <div class="flex items-center gap-2">
      <SidebarTrigger class="-ml-1" />
      <template v-if="breadcrumbs && breadcrumbs.length > 0">
        <Breadcrumbs :breadcrumbs="breadcrumbs" />
      </template>
    </div>

    <div v-if="hasAcademicPeriods" class="ml-auto flex items-center gap-2">
      <DropdownMenu>
        <DropdownMenuTrigger :as-child="true">
          <Button variant="outline" size="sm" class="h-8 max-w-56 gap-2">
            <CalendarDays class="h-4 w-4 shrink-0" />
            <span class="truncate">{{ activePeriodLabel }}</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" class="w-72">
          <DropdownMenuLabel>{{ t("nav.current_period") }}</DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuItem
            v-for="period in availableAcademicPeriods"
            :key="period.id"
            :as-child="true"
          >
            <Link
              :href="academicPeriodPath(period.id)"
              class="flex w-full items-center justify-between gap-3"
            >
              <span class="truncate">{{ period.name }}</span>
              <Check
                v-if="period.id === activePeriodId"
                class="text-primary h-4 w-4"
              />
            </Link>
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem :as-child="true">
            <Link :href="academicPeriodsPath()" class="block w-full">
              {{ t("nav.view_all_periods") }}
            </Link>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  </header>
</template>
