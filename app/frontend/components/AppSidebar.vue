<script setup lang="ts">
import { Link, usePage } from "@inertiajs/vue3"
import { CalendarDays, LayoutGrid, MessageCircle, Users } from "lucide-vue-next"
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
import {
  academicPeriodPath,
  academicPeriodsPath,
  aiConversationsPath,
  dashboardPath,
} from "@/routes"
import { type Auth, type NavItem } from "@/types"

import AppLogo from "./AppLogo.vue"

const { t } = useI18n()
const { can, isTutor, isTutorado } = usePermissions()
const page = usePage()

const auth = computed(() => page.props.auth as Partial<Auth> | undefined)
const academicPeriodContext = computed(() => {
  return auth.value?.academic_period_context ?? { active: null, available: [] }
})
const currentAcademicPeriod = computed(() => academicPeriodContext.value.active)
const currentPeriodHref = computed(() => {
  return currentAcademicPeriod.value
    ? academicPeriodPath(currentAcademicPeriod.value.id)
    : academicPeriodsPath()
})

const mainNavItems = computed<NavItem[]>(() => {
  const items: NavItem[] = [
    {
      title: t("nav.dashboard"),
      href: dashboardPath(),
      icon: LayoutGrid,
    },
  ]

  // Admin: grouped academic management
  if (can.value.manage_academic_periods) {
    const academicManagementItems: NavItem[] = []

    if (currentAcademicPeriod.value) {
      academicManagementItems.push({
        title: t("nav.current_period"),
        href: currentPeriodHref.value,
        icon: CalendarDays,
      })
    }

    academicManagementItems.push({
      title: t("nav.academic_periods"),
      href: academicPeriodsPath(),
      icon: CalendarDays,
    })

    items.push({
      title: t("nav.academic_management"),
      icon: CalendarDays,
      defaultOpen: true,
      items: academicManagementItems,
    })
  }

  // Tutor/Tutorado: grouped learning/teaching entry point
  if (isTutor.value || isTutorado.value) {
    items.push({
      title: isTutor.value ? t("nav.teaching") : t("nav.learning"),
      icon: Users,
      defaultOpen: true,
      items: [
        {
          title: t("nav.current_period"),
          href: currentPeriodHref.value,
          icon: CalendarDays,
        },
      ],
    })
  }

  // AI Chat: available to all roles
  items.push({
    title: t("nav.ai_chat"),
    href: aiConversationsPath(),
    icon: MessageCircle,
  })

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
