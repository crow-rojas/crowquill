<script setup lang="ts">
import { Link } from "@inertiajs/vue3"
import { CalendarDays, LayoutGrid } from "lucide-vue-next"
import { computed } from "vue"
import { useI18n } from "vue-i18n"

import NavMain from "@/components/NavMain.vue"
import NavUser from "@/components/NavUser.vue"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { usePermissions } from "@/composables/usePermissions"
import { academicPeriodsPath, dashboardPath } from "@/routes"
import { type NavItem } from "@/types"

import AppLogo from "./AppLogo.vue"

const { t } = useI18n()
const { can } = usePermissions()

const mainNavItems = computed<NavItem[]>(() => {
  const items: NavItem[] = [
    {
      title: t("nav.dashboard"),
      href: dashboardPath(),
      icon: LayoutGrid,
    },
  ]

  if (can.value.manage_academic_periods) {
    items.push({
      title: t("nav.academic_periods"),
      href: academicPeriodsPath(),
      icon: CalendarDays,
    })
  }

  return items
})
</script>

<template>
  <Sidebar collapsible="icon" variant="inset">
    <SidebarHeader>
      <SidebarMenu>
        <SidebarMenuItem>
          <SidebarMenuButton size="lg" as-child>
            <Link :href="dashboardPath()">
              <AppLogo />
            </Link>
          </SidebarMenuButton>
        </SidebarMenuItem>
      </SidebarMenu>
    </SidebarHeader>

    <SidebarContent>
      <NavMain :items="mainNavItems" />
    </SidebarContent>

    <SidebarFooter>
      <NavUser />
    </SidebarFooter>
  </Sidebar>
  <slot />
</template>
