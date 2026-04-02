<script setup lang="ts">
import { Link, usePage } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import {
  SidebarGroup,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { type NavItem } from "@/types"

defineProps<{
  items: NavItem[]
}>()

const page = usePage()
const { t } = useI18n()

function isActive(itemHref: string): boolean {
  const cleanUrl = page.url.split("?")[0]
  if (itemHref === "/") {
    return cleanUrl === "/"
  }
  return cleanUrl === itemHref || cleanUrl.startsWith(itemHref + "/")
}
</script>

<template>
  <SidebarGroup class="px-2 py-0">
    <SidebarGroupLabel>{{ t("nav.platform") }}</SidebarGroupLabel>
    <SidebarMenu>
      <SidebarMenuItem v-for="item in items" :key="item.title">
        <SidebarMenuButton
          as-child
          :is-active="isActive(item.href)"
          :tooltip="item.title"
        >
          <Link :href="item.href">
            <component :is="item.icon" />
            <span>{{ item.title }}</span>
          </Link>
        </SidebarMenuButton>
      </SidebarMenuItem>
    </SidebarMenu>
  </SidebarGroup>
</template>
