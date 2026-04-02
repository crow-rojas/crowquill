<script setup lang="ts">
import { Head } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import AppLayout from "@/layouts/AppLayout.vue"

const { t } = useI18n()
</script>

<template>
  <Head :title="t('common.appName')" />

  <AppLayout :breadcrumbs="[]">
    <div class="flex h-full flex-1 items-center justify-center p-4">
      <div class="max-w-md text-center">
        <h1 class="text-2xl font-semibold">
          {{ t("onboarding.title") }}
        </h1>
        <p class="text-muted-foreground mt-2">
          {{ t("onboarding.description") }}
        </p>
      </div>
    </div>
  </AppLayout>
</template>
