<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"
import { LoaderCircle } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import InputError from "@/components/InputError.vue"
import TextLink from "@/components/TextLink.vue"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import AuthBase from "@/layouts/AuthLayout.vue"
import { newIdentityPasswordResetPath, signInPath, signUpPath } from "@/routes"

const { t } = useI18n()
</script>

<template>
  <AuthBase
    :title="t('auth.login.title')"
    :description="t('auth.login.description')"
  >
    <Head :title="t('auth.login.submit')" />

    <Form
      method="post"
      :action="signInPath()"
      :resetOnSuccess="['password']"
      class="flex flex-col gap-6"
      #default="{ errors, processing }"
    >
      <div class="grid gap-6">
        <div class="grid gap-2">
          <Label for="email">{{ t("auth.login.email") }}</Label>
          <Input
            id="email"
            name="email"
            type="email"
            required
            autofocus
            :tabindex="1"
            autocomplete="email"
            placeholder="email@example.com"
          />
          <InputError :messages="errors.email" />
        </div>

        <div class="grid gap-2">
          <div class="flex items-center justify-between">
            <Label for="password">{{ t("auth.login.password") }}</Label>
            <TextLink
              :href="newIdentityPasswordResetPath()"
              class="text-sm"
              :tabindex="5"
            >
              {{ t("auth.login.forgotPassword") }}
            </TextLink>
          </div>
          <Input
            id="password"
            name="password"
            type="password"
            required
            :tabindex="2"
            autocomplete="current-password"
            :placeholder="t('auth.login.password')"
          />
          <InputError :messages="errors.password" />
        </div>

        <Button
          type="submit"
          class="mt-4 w-full"
          :tabindex="4"
          :disabled="processing"
        >
          <LoaderCircle v-if="processing" class="h-4 w-4 animate-spin" />
          {{ t("auth.login.submit") }}
        </Button>
      </div>

      <div class="text-muted-foreground text-center text-sm">
        {{ t("auth.login.noAccount") }}
        <TextLink :href="signUpPath()" :tabindex="5">{{
          t("auth.login.signUp")
        }}</TextLink>
      </div>
    </Form>
  </AuthBase>
</template>
