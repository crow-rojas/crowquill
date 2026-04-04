<script setup lang="ts">
import { Link, usePage } from "@inertiajs/vue3"
import { BookOpen, LayoutGrid, MessageCircle } from "lucide-vue-next"
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
import {
  academicPeriodCoursesPath,
  academicPeriodsPath,
  aiConversationsPath,
  dashboardPath,
} from "@/routes"
import { type Auth, type NavItem } from "@/types"

import AppLogo from "./AppLogo.vue"

const { t } = useI18n()
const page = usePage()

const auth = computed(() => page.props.auth as Partial<Auth> | undefined)
const academicPeriodContext = computed(() => {
  return auth.value?.academic_period_context ?? { active: null, available: [] }
})
const currentAcademicPeriod = computed(() => academicPeriodContext.value.active)
const coursesHref = computed(() => {
  return currentAcademicPeriod.value
    ? academicPeriodCoursesPath(currentAcademicPeriod.value.id)
    : academicPeriodsPath()
})

const mainNavItems = computed<NavItem[]>(() => [
  {
    title: t("nav.dashboard"),
    href: dashboardPath(),
    icon: LayoutGrid,
  },
  {
    title: t("nav.courses"),
    href: coursesHref.value,
    icon: BookOpen,
  },
  {
    title: t("nav.ai_chat"),
    href: aiConversationsPath(),
    icon: MessageCircle,
  },
])
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
