<script setup lang="ts">
import { Link } from "@inertiajs/vue3"

import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"

interface BreadcrumbItemType {
  title: string
  href?: string
}

defineProps<{
  breadcrumbs: BreadcrumbItemType[]
}>()
</script>

<template>
  <Breadcrumb class="w-full min-w-0">
    <div
      class="overflow-x-auto [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
    >
      <BreadcrumbList
        class="w-max min-w-full flex-nowrap py-0.5 whitespace-nowrap"
      >
        <template v-for="(item, index) in breadcrumbs" :key="index">
          <BreadcrumbItem
            :class="[
              'min-w-0 shrink-0',
              index === breadcrumbs.length - 1
                ? 'max-w-[11rem] sm:max-w-[16rem] md:max-w-none'
                : 'max-w-[9rem] sm:max-w-[14rem] md:max-w-none',
            ]"
          >
            <template v-if="index === breadcrumbs.length - 1">
              <BreadcrumbPage class="block truncate" :title="item.title">
                {{ item.title }}
              </BreadcrumbPage>
            </template>
            <template v-else>
              <BreadcrumbLink as-child>
                <Link
                  :href="item.href ?? '#'"
                  :title="item.title"
                  class="block truncate"
                >
                  {{ item.title }}
                </Link>
              </BreadcrumbLink>
            </template>
          </BreadcrumbItem>
          <BreadcrumbSeparator
            v-if="index !== breadcrumbs.length - 1"
            class="shrink-0"
          />
        </template>
      </BreadcrumbList>
    </div>
  </Breadcrumb>
</template>
