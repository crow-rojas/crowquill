<script setup lang="ts">
import { Head, Link, useForm } from "@inertiajs/vue3"
import { MessageCircle, Plus } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Button } from "@/components/ui/button"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  aiConversationPath,
  aiConversationsPath,
  dashboardPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { AiConversation } from "@/types/academic"

defineProps<{
  conversations: AiConversation[]
}>()

const { t } = useI18n()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  { title: t("ai.title"), href: "#" },
]

const form = useForm({
  ai_conversation: {
    title: "",
  },
})

function createConversation() {
  const now = new Date()
  form.ai_conversation.title = `${t("ai.new_conversation")} - ${now.toLocaleDateString()}`
  form.post(aiConversationsPath())
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  })
}
</script>

<template>
  <Head :title="t('ai.title')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t("ai.title") }}
        </h1>
        <Button size="sm" @click="createConversation">
          <Plus class="mr-1 h-4 w-4" />
          {{ t("ai.new_conversation") }}
        </Button>
      </div>

      <div
        v-if="conversations.length === 0"
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <MessageCircle class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("ai.no_conversations") }}</p>
      </div>

      <div v-else class="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>{{ t("ai.conversations") }}</TableHead>
              <TableHead class="text-right">{{
                t("common.actions")
              }}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow
              v-for="conversation in conversations"
              :key="conversation.id"
            >
              <TableCell>
                <div class="space-y-1">
                  <Link
                    :href="aiConversationPath(conversation.id)"
                    class="font-medium hover:underline"
                  >
                    {{ conversation.title }}
                  </Link>
                  <p class="text-muted-foreground text-sm">
                    {{ formatDate(conversation.updated_at) }}
                  </p>
                </div>
              </TableCell>
              <TableCell class="text-right">
                <Button variant="outline" size="sm" as-child>
                  <Link :href="aiConversationPath(conversation.id)">
                    {{ t("common.view") }}
                  </Link>
                </Button>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </div>
  </AppLayout>
</template>
