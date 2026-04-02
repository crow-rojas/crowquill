<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { Plus, Users } from "lucide-vue-next"
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
import { usePermissions } from "@/composables/usePermissions"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodsPath,
  coursePath,
  dashboardPath,
  editSectionPath,
  newCourseSectionPath,
  sectionPath,
  sectionTutoringSessionsPath,
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
  { title: t("nav.dashboard"), href: dashboardPath() },
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

      <div v-else class="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>{{ t("sections.name") }}</TableHead>
              <TableHead>{{ t("sections.tutor") }}</TableHead>
              <TableHead class="text-right">{{
                t("sections.max_students")
              }}</TableHead>
              <TableHead class="text-right">{{
                t("common.actions")
              }}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="section in sections" :key="section.id">
              <TableCell class="font-medium">
                <Link :href="sectionPath(section.id)" class="hover:underline">
                  {{ section.name }}
                </Link>
              </TableCell>
              <TableCell>{{ section.tutor?.name || "-" }}</TableCell>
              <TableCell class="text-right">{{
                section.max_students
              }}</TableCell>
              <TableCell class="text-right">
                <div class="flex flex-wrap justify-end gap-2">
                  <Button variant="outline" size="sm" as-child>
                    <Link :href="sectionPath(section.id)">
                      {{ t("common.view") }}
                    </Link>
                  </Button>
                  <Button
                    v-if="section.can_view_sessions"
                    variant="outline"
                    size="sm"
                    as-child
                  >
                    <Link :href="sectionTutoringSessionsPath(section.id)">
                      {{ t("sections.sessions_action") }}
                    </Link>
                  </Button>
                  <Button
                    v-if="can.manage_sections"
                    variant="outline"
                    size="sm"
                    as-child
                  >
                    <Link :href="editSectionPath(section.id)">
                      {{ t("common.edit") }}
                    </Link>
                  </Button>
                  <Button
                    v-if="can.manage_sections"
                    variant="outline"
                    size="sm"
                    class="text-destructive"
                    @click="deleteSection(section)"
                  >
                    {{ t("common.delete") }}
                  </Button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </div>
  </AppLayout>
</template>
