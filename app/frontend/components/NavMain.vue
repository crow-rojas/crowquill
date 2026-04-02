<script setup lang="ts">
import { Link, usePage } from "@inertiajs/vue3"
import { ChevronRight } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible"
import {
  SidebarGroup,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarMenuSub,
  SidebarMenuSubButton,
  SidebarMenuSubItem,
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

function hasChildren(item: NavItem): boolean {
  return Array.isArray(item.items) && item.items.length > 0
}

function isItemActive(item: NavItem): boolean {
  if (item.href && isActive(item.href)) {
    return true
  }

  if (!hasChildren(item)) {
    return false
  }

  return item.items!.some((subItem) => isItemActive(subItem))
}
</script>

<template>
  <SidebarGroup class="px-2 py-0">
    <SidebarGroupLabel>{{ t("nav.platform") }}</SidebarGroupLabel>
    <SidebarMenu>
      <template v-for="item in items" :key="item.title">
        <Collapsible
          v-if="hasChildren(item)"
          :default-open="item.defaultOpen ?? isItemActive(item)"
          class="group/collapsible"
        >
          <SidebarMenuItem>
            <CollapsibleTrigger as-child>
              <SidebarMenuButton
                :is-active="isItemActive(item)"
                :tooltip="item.title"
              >
                <component v-if="item.icon" :is="item.icon" />
                <span>{{ item.title }}</span>
                <ChevronRight
                  class="ml-auto transition-transform duration-200 group-data-[state=open]/collapsible:rotate-90"
                />
              </SidebarMenuButton>
            </CollapsibleTrigger>

            <CollapsibleContent>
              <SidebarMenuSub>
                <SidebarMenuSubItem
                  v-for="subItem in item.items"
                  :key="subItem.title"
                >
                  <SidebarMenuSubButton
                    v-if="subItem.href"
                    as-child
                    :is-active="isActive(subItem.href)"
                  >
                    <Link :href="subItem.href">
                      <component v-if="subItem.icon" :is="subItem.icon" />
                      <span>{{ subItem.title }}</span>
                    </Link>
                  </SidebarMenuSubButton>
                </SidebarMenuSubItem>
              </SidebarMenuSub>
            </CollapsibleContent>
          </SidebarMenuItem>
        </Collapsible>

        <SidebarMenuItem v-else>
          <SidebarMenuButton
            v-if="item.href"
            as-child
            :is-active="isActive(item.href)"
            :tooltip="item.title"
          >
            <Link :href="item.href">
              <component v-if="item.icon" :is="item.icon" />
              <span>{{ item.title }}</span>
            </Link>
          </SidebarMenuButton>
        </SidebarMenuItem>
      </template>
    </SidebarMenu>
  </SidebarGroup>
</template>
