<script setup lang="ts">
import { Form, Head } from "@inertiajs/vue3"
import { LoaderCircle } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import InputError from "@/components/InputError.vue"
import TextLink from "@/components/TextLink.vue"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import AuthLayout from "@/layouts/AuthLayout.vue"
import { identityPasswordResetPath, signInPath } from "@/routes"

const { t } = useI18n()
</script>

<template>
  <AuthLayout
    :title="t('auth.forgotPassword.title')"
    :description="t('auth.forgotPassword.description')"
  >
    <Head :title="t('auth.forgotPassword.title')" />

    <div class="space-y-6">
      <Form
        method="post"
        :action="identityPasswordResetPath()"
        #default="{ errors, processing }"
      >
        <div class="grid gap-2">
          <Label for="email">{{ t("auth.login.email") }}</Label>
          <Input
            id="email"
            name="email"
            type="email"
            autocomplete="off"
            autofocus
            placeholder="email@example.com"
          />
          <InputError :messages="errors.email" />
        </div>

        <div class="my-6 flex items-center justify-start">
          <Button class="w-full" :disabled="processing">
            <LoaderCircle v-if="processing" class="h-4 w-4 animate-spin" />
            {{ t("auth.forgotPassword.submit") }}
          </Button>
        </div>
      </Form>

      <div class="text-muted-foreground space-x-1 text-center text-sm">
        <span>{{ t("auth.forgotPassword.backToLogin") }}</span>
        <TextLink :href="signInPath()">{{ t("auth.login.submit") }}</TextLink>
      </div>
    </div>
  </AuthLayout>
</template>
