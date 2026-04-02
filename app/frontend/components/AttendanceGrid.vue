<script setup lang="ts">
import { useForm } from "@inertiajs/vue3"
import { computed, watch } from "vue"
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
import type { Attendance, Enrollment } from "@/types/academic"

const props = defineProps<{
  tutoringSessionId: number
  enrollments: Enrollment[]
  attendances: Attendance[]
  readonly?: boolean
}>()

const { t } = useI18n()

interface AttendanceEntry {
  enrollment_id: number
  status: "present" | "absent" | "justified"
  notes: string
}

const initialEntries = computed<AttendanceEntry[]>(() =>
  props.enrollments.map((enrollment) => {
    const existing = props.attendances.find(
      (a) => a.enrollment_id === enrollment.id,
    )
    return {
      enrollment_id: enrollment.id,
      status: existing?.status ?? "absent",
      notes: existing?.notes ?? "",
    }
  }),
)

const form = useForm<{ attendances: AttendanceEntry[] }>({
  attendances: initialEntries.value,
})

watch(
  () => [props.enrollments, props.attendances],
  () => {
    form.defaults({ attendances: initialEntries.value })
    form.reset()
  },
  { deep: true },
)

function getStatus(enrollmentId: number): string {
  return (
    form.attendances.find((a) => a.enrollment_id === enrollmentId)?.status ??
    "absent"
  )
}

function setStatus(
  enrollmentId: number,
  status: "present" | "absent" | "justified",
) {
  const entry = form.attendances.find((a) => a.enrollment_id === enrollmentId)
  if (entry) {
    entry.status = status
  }
}

function statusButtonVariant(
  enrollmentId: number,
  status: string,
): "default" | "outline" {
  return getStatus(enrollmentId) === status ? "default" : "outline"
}

function submit() {
  form.patch(`/tutoring_sessions/${props.tutoringSessionId}/attendances`)
}
</script>

<template>
  <div>
    <div
      v-if="enrollments.length === 0"
      class="text-muted-foreground py-4 text-center text-sm"
    >
      {{ t("attendance.no_enrollments") }}
    </div>

    <form v-else @submit.prevent="submit">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{{ t("attendance.student") }}</TableHead>
            <TableHead>{{ t("attendance.status") }}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="enrollment in enrollments" :key="enrollment.id">
            <TableCell>
              <div>
                <p class="font-medium">{{ enrollment.user?.name }}</p>
                <p class="text-muted-foreground text-sm">
                  {{ enrollment.user?.email }}
                </p>
              </div>
            </TableCell>
            <TableCell>
              <div class="flex gap-1">
                <Button
                  type="button"
                  size="sm"
                  :variant="statusButtonVariant(enrollment.id, 'present')"
                  :disabled="readonly"
                  class="min-h-[44px] min-w-[44px]"
                  @click="setStatus(enrollment.id, 'present')"
                >
                  {{ t("attendance.statuses.present") }}
                </Button>
                <Button
                  type="button"
                  size="sm"
                  :variant="statusButtonVariant(enrollment.id, 'absent')"
                  :disabled="readonly"
                  class="min-h-[44px] min-w-[44px]"
                  @click="setStatus(enrollment.id, 'absent')"
                >
                  {{ t("attendance.statuses.absent") }}
                </Button>
                <Button
                  type="button"
                  size="sm"
                  :variant="statusButtonVariant(enrollment.id, 'justified')"
                  :disabled="readonly"
                  class="min-h-[44px] min-w-[44px]"
                  @click="setStatus(enrollment.id, 'justified')"
                >
                  {{ t("attendance.statuses.justified") }}
                </Button>
              </div>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>

      <div v-if="!readonly" class="mt-4 flex justify-end">
        <Button type="submit" :disabled="form.processing">
          {{ t("attendance.save_attendance") }}
        </Button>
      </div>
    </form>
  </div>
</template>
