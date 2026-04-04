<script setup lang="ts">
import { Users } from "lucide-vue-next"
import { useI18n } from "vue-i18n"

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import type { Enrollment } from "@/types/academic"

const props = defineProps<{
  enrollments: Enrollment[]
  studentSummaries: Record<
    number,
    { present: number; absent: number; justified: number }
  > | null
}>()

const { t } = useI18n()

function getSummary(enrollmentId: number) {
  return (
    props.studentSummaries?.[enrollmentId] ?? {
      present: 0,
      absent: 0,
      justified: 0,
    }
  )
}
</script>

<template>
  <div class="space-y-4">
    <div
      v-if="enrollments.length === 0"
      class="text-muted-foreground flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center"
    >
      <Users class="mb-4 h-12 w-12 opacity-40" />
      <p>{{ t("attendance.no_enrollments") }}</p>
    </div>

    <div v-else class="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{{ t("sessions.student_name") }}</TableHead>
            <TableHead>{{ t("sessions.student_email") }}</TableHead>
            <TableHead class="text-center">
              {{ t("sessions.attendance_present") }}
            </TableHead>
            <TableHead class="text-center">
              {{ t("sessions.attendance_absent") }}
            </TableHead>
            <TableHead class="text-center">
              {{ t("sessions.attendance_justified") }}
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="enrollment in enrollments" :key="enrollment.id">
            <TableCell class="font-medium">
              {{ enrollment.user?.name }}
            </TableCell>
            <TableCell class="text-muted-foreground">
              {{ enrollment.user?.email }}
            </TableCell>
            <TableCell class="text-center">
              {{ getSummary(enrollment.id).present }}
            </TableCell>
            <TableCell class="text-center">
              {{ getSummary(enrollment.id).absent }}
            </TableCell>
            <TableCell class="text-center">
              {{ getSummary(enrollment.id).justified }}
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
  </div>
</template>
