<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import AppearanceTabs from "@/components/AppearanceTabs.vue"
import HeadingSmall from "@/components/HeadingSmall.vue"
import AppLayout from "@/layouts/AppLayout.vue"
import SettingsLayout from "@/layouts/settings/Layout.vue"
import { settingsAppearancePath } from "@/routes"
import { type BreadcrumbItem } from "@/types"

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  {
    title: t("settings.appearance.breadcrumb"),
    href: settingsAppearancePath(),
  },
]
</script>

<template>
  <AppLayout :breadcrumbs="breadcrumbs">
    <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

    <SettingsLayout>
      <div class="space-y-6">
        <HeadingSmall
          :title="t('settings.appearance.title')"
          :description="t('settings.appearance.description')"
        />
        <AppearanceTabs />
      </div>
    </SettingsLayout>
  </AppLayout>
</template>
