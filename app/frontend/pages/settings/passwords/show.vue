<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"
import { useI18n } from "vue-i18n"

import HeadingSmall from "@/components/HeadingSmall.vue"
import InputError from "@/components/InputError.vue"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import AppLayout from "@/layouts/AppLayout.vue"
import SettingsLayout from "@/layouts/settings/Layout.vue"
import { settingsPasswordPath } from "@/routes"
import { type BreadcrumbItem } from "@/types"

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  {
    title: t("settings.password.breadcrumb"),
    href: settingsPasswordPath(),
  },
]
</script>

<template>
  <AppLayout :breadcrumbs="breadcrumbs">
    <Head :title="breadcrumbs[breadcrumbs.length - 1].title" />

    <SettingsLayout>
      <div class="space-y-6">
        <HeadingSmall
          :title="t('settings.password.title')"
          :description="t('settings.password.description')"
        />

        <Form
          class="space-y-6"
          method="put"
          :action="settingsPasswordPath()"
          :options="{ preserveScroll: true }"
          resetOnError
          resetOnSuccess
          #default="{ errors, processing, recentlySuccessful }"
        >
          <div class="grid gap-2">
            <Label for="password_challenge">{{
              t("settings.password.currentPassword")
            }}</Label>
            <Input
              id="password_challenge"
              name="password_challenge"
              type="password"
              class="mt-1 block w-full"
              autocomplete="current-password"
              :placeholder="t('settings.password.currentPasswordPlaceholder')"
            />
            <InputError :messages="errors.password_challenge" />
          </div>

          <div class="grid gap-2">
            <Label for="password">{{
              t("settings.password.newPassword")
            }}</Label>
            <Input
              id="password"
              name="password"
              type="password"
              class="mt-1 block w-full"
              autocomplete="new-password"
              :placeholder="t('settings.password.newPasswordPlaceholder')"
            />
            <InputError :messages="errors.password" />
          </div>

          <div class="grid gap-2">
            <Label for="password_confirmation">{{
              t("settings.password.confirmPassword")
            }}</Label>
            <Input
              id="password_confirmation"
              name="password_confirmation"
              type="password"
              class="mt-1 block w-full"
              autocomplete="new-password"
              :placeholder="t('settings.password.confirmPasswordPlaceholder')"
            />
            <InputError :messages="errors.password_confirmation" />
          </div>

          <div class="flex items-center gap-4">
            <Button :disabled="processing">{{
              t("settings.password.submit")
            }}</Button>

            <Transition
              enter-active-class="transition ease-in-out"
              enter-from-class="opacity-0"
              leave-active-class="transition ease-in-out"
              leave-to-class="opacity-0"
            >
              <p v-show="recentlySuccessful" class="text-sm text-neutral-600">
                {{ t("settings.password.saved") }}
              </p>
            </Transition>
          </div>
        </Form>
      </div>
    </SettingsLayout>
  </AppLayout>
</template>
