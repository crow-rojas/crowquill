<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { Plus, Users } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodsPath,
  coursePath,
  editSectionPath,
  newCourseSectionPath,
  sectionPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type { Course, Section } from "@/types/academic"

const props = defineProps<{
  course: Course
  sections: Section[]
}>()

const { t } = useI18n()
const { can } = usePermissions()

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: "/dashboard" },
  { title: t("academic_periods.title"), href: academicPeriodsPath() },
  { title: props.course.name, href: coursePath(props.course.id) },
  { title: t("sections.title"), href: "#" },
]

function deleteSection(section: Section) {
  if (confirm(t("sections.confirm_delete"))) {
    router.delete(sectionPath(section.id))
  }
}
</script>

<template>
  <Head :title="t('sections.title')" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t("sections.title") }}
        </h1>
        <Button v-if="can.manage_sections" as-child size="sm">
          <Link :href="newCourseSectionPath(course.id)">
            <Plus class="mr-1 h-4 w-4" />
            {{ t("sections.new") }}
          </Link>
        </Button>
      </div>

      <div
        v-if="sections.length === 0"
        class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
      >
        <Users class="mb-4 h-12 w-12 opacity-40" />
        <p>{{ t("sections.no_sections") }}</p>
      </div>

      <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Card v-for="section in sections" :key="section.id">
          <CardHeader>
            <CardTitle class="text-lg">
              <Link :href="sectionPath(section.id)" class="hover:underline">
                {{ section.name }}
              </Link>
            </CardTitle>
            <CardDescription v-if="section.tutor">
              {{ t("sections.tutor") }}: {{ section.tutor.name }}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div class="flex flex-col gap-2">
              <div
                class="text-muted-foreground flex items-center gap-1 text-sm"
              >
                <Users class="h-4 w-4" />
                <span
                  >{{ t("sections.max_students") }}:
                  {{ section.max_students }}</span
                >
              </div>
              <div v-if="can.manage_sections" class="flex gap-2 pt-2">
                <Button variant="outline" size="sm" as-child>
                  <Link :href="editSectionPath(section.id)">
                    {{ t("common.edit") }}
                  </Link>
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  class="text-destructive"
                  @click="deleteSection(section)"
                >
                  {{ t("common.delete") }}
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </AppLayout>
</template>
