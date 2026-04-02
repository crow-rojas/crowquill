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
import { signInPath, signUpPath } from "@/routes"

const { t } = useI18n()
</script>

<template>
  <AuthBase
    :title="t('auth.register.title')"
    :description="t('auth.register.description')"
  >
    <Head :title="t('auth.register.submit')" />

    <Form
      method="post"
      :action="signUpPath()"
      :resetOnSuccess="['password', 'password_confirmation']"
      disableWhileProcessing
      class="flex flex-col gap-6"
      #default="{ errors, processing }"
    >
      <div class="grid gap-6">
        <div class="grid gap-2">
          <Label for="name">{{ t("auth.register.name") }}</Label>
          <Input
            id="name"
            name="name"
            type="text"
            required
            autofocus
            :tabindex="1"
            autocomplete="name"
            :placeholder="t('auth.register.name')"
          />
          <InputError :messages="errors.name" />
        </div>

        <div class="grid gap-2">
          <Label for="email">{{ t("auth.register.email") }}</Label>
          <Input
            id="email"
            name="email"
            type="email"
            required
            :tabindex="2"
            autocomplete="email"
            placeholder="email@example.com"
          />
          <InputError :messages="errors.email" />
        </div>

        <div class="grid gap-2">
          <Label for="password">{{ t("auth.register.password") }}</Label>
          <Input
            id="password"
            name="password"
            type="password"
            required
            :tabindex="3"
            autocomplete="new-password"
            :placeholder="t('auth.register.password')"
          />
          <InputError :messages="errors.password" />
        </div>

        <div class="grid gap-2">
          <Label for="password_confirmation">{{
            t("auth.register.passwordConfirmation")
          }}</Label>
          <Input
            id="password_confirmation"
            name="password_confirmation"
            type="password"
            required
            :tabindex="4"
            autocomplete="new-password"
            :placeholder="t('auth.register.passwordConfirmation')"
          />
          <InputError :messages="errors.password_confirmation" />
        </div>

        <Button
          type="submit"
          class="mt-2 w-full"
          :tabindex="5"
          :disabled="processing"
        >
          <LoaderCircle v-if="processing" class="h-4 w-4 animate-spin" />
          {{ t("auth.register.submit") }}
        </Button>
      </div>

      <div class="text-muted-foreground text-center text-sm">
        {{ t("auth.register.hasAccount") }}
        <TextLink
          :href="signInPath()"
          class="underline underline-offset-4"
          :tabindex="6"
          >{{ t("auth.register.signIn") }}</TextLink
        >
      </div>
    </Form>
  </AuthBase>
</template>
