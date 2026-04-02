<script setup lang="ts">
import { Form } from "@inertiajs/vue3"
import { ref } from "vue"
import { useI18n } from "vue-i18n"

import HeadingSmall from "@/components/HeadingSmall.vue"
import InputError from "@/components/InputError.vue"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { usersPath } from "@/routes"

const { t } = useI18n()
const passwordInput = ref<HTMLInputElement | null>(null)
</script>

<template>
  <div class="space-y-6">
    <HeadingSmall
      :title="t('settings.deleteAccount.title')"
      :description="t('settings.deleteAccount.description')"
    />
    <div
      class="space-y-4 rounded-lg border border-red-100 bg-red-50 p-4 dark:border-red-200/10 dark:bg-red-700/10"
    >
      <div class="relative space-y-0.5 text-red-600 dark:text-red-100">
        <p class="font-medium">{{ t("settings.deleteAccount.warning") }}</p>
        <p class="text-sm">
          {{ t("settings.deleteAccount.warningText") }}
        </p>
      </div>
      <Dialog>
        <DialogTrigger as-child>
          <Button variant="destructive">{{
            t("settings.deleteAccount.button")
          }}</Button>
        </DialogTrigger>
        <DialogContent>
          <Form
            method="delete"
            :action="usersPath()"
            :options="{ preserveScroll: true }"
            :onError="() => passwordInput?.focus()"
            resetOnSuccess
            className="space-y-6"
            #default="{ resetAndClearErrors, processing, errors }"
          >
            <DialogHeader class="space-y-3">
              <DialogTitle>{{
                t("settings.deleteAccount.dialogTitle")
              }}</DialogTitle>
              <DialogDescription>
                {{ t("settings.deleteAccount.dialogDescription") }}
              </DialogDescription>
            </DialogHeader>

            <div class="grid gap-2">
              <Label for="password_challenge" class="sr-only">{{
                t("settings.deleteAccount.password")
              }}</Label>
              <Input
                id="password_challenge"
                type="password"
                name="password_challenge"
                ref="passwordInput"
                :placeholder="t('settings.deleteAccount.passwordPlaceholder')"
              />
              <InputError :messages="errors.password_challenge" />
            </div>

            <DialogFooter class="gap-2">
              <DialogClose as-child>
                <Button variant="secondary" @click="resetAndClearErrors">
                  {{ t("common.cancel") }}
                </Button>
              </DialogClose>

              <Button
                type="submit"
                variant="destructive"
                :disabled="processing"
              >
                {{ t("settings.deleteAccount.button") }}
              </Button>
            </DialogFooter>
          </Form>
        </DialogContent>
      </Dialog>
    </div>
  </div>
</template>
