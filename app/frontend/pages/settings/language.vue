<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
import { Globe } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import HeadingSmall from "@/components/HeadingSmall.vue"
import { setLocale } from "@/i18n"
import AppLayout from "@/layouts/AppLayout.vue"
import SettingsLayout from "@/layouts/settings/Layout.vue"
import { settingsLanguagePath } from "@/routes"
import { type BreadcrumbItem } from "@/types"

const { t, locale } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  {
    title: t("settings.language.title"),
    href: settingsLanguagePath(),
  },
]

const languages = [
  { code: "es" as const, label: "Español", flag: "1f1f2-1f1fd" },
  { code: "en" as const, label: "English", flag: "1f1fa-1f1f8" },
]

function switchLanguage(code: "es" | "en") {
  setLocale(code)
}
</script>

<template>
  <AppLayout :breadcrumbs="breadcrumbs">
    <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

    <SettingsLayout>
      <div class="space-y-6">
        <HeadingSmall
          :title="t('settings.language.title')"
          :description="t('settings.language.description')"
        />

        <div class="grid gap-3">
          <button
            v-for="lang in languages"
            :key="lang.code"
            @click="switchLanguage(lang.code)"
            :class="[
              'flex items-center gap-3 rounded-lg border px-4 py-3 text-left transition-colors',
              locale === lang.code
                ? 'border-primary bg-primary/5 ring-primary/20 ring-1'
                : 'hover:bg-muted/50',
            ]"
          >
            <img
              :src="`https://cdn.jsdelivr.net/gh/jdecked/twemoji@latest/assets/svg/${lang.flag}.svg`"
              :alt="lang.label"
              class="h-5 w-5 shrink-0"
            />
            <span class="font-medium">{{ lang.label }}</span>
            <Globe
              v-if="locale === lang.code"
              class="text-primary ml-auto h-4 w-4"
            />
          </button>
        </div>
      </div>
    </SettingsLayout>
  </AppLayout>
</template>
