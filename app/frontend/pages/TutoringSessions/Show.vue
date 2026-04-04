<script setup lang="ts">
import { Head, Link, router } from "@inertiajs/vue3"
import { Calendar, MessageCircle } from "lucide-vue-next"
import { computed } from "vue"
import { useI18n } from "vue-i18n"

import AttendanceGrid from "@/components/AttendanceGrid.vue"
import SessionExercises from "@/components/SessionExercises.vue"
import SessionStudents from "@/components/SessionStudents.vue"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import AppLayout from "@/layouts/AppLayout.vue"
import {
  academicPeriodCoursesPath,
  aiConversationsPath,
  coursePath,
  dashboardPath,
  editTutoringSessionPath,
  sectionPath,
  sectionTutoringSessionsPath,
  tutoringSessionPath,
} from "@/routes"
import type { BreadcrumbItem } from "@/types"
import type {
  Attendance,
  Course,
  Enrollment,
  ExerciseSet,
  Section,
  TutoringSession,
} from "@/types/academic"

const props = defineProps<{
  tutoring_session: TutoringSession & {
    section: Section & {
      course: Course
      tutor?: { id: number; name: string; email: string }
    }
  }
  enrollments: Enrollment[]
  attendances: Attendance[]
  exercise_sets: ExerciseSet[]
  exercise_match_type: "week" | "all"
  student_summaries: Record<
    number,
    { present: number; absent: number; justified: number }
  > | null
  ai_chat_exercise_set_id: number | null
  can_manage_session: boolean
  can_take_attendance: boolean
  can_delete_session: boolean
}>()

const { t } = useI18n()
const ownAttendance = computed(() => props.attendances[0] ?? null)
const weekNumber = computed(() => props.exercise_sets[0]?.week_number)
const exerciseTitle = computed(
  () => props.exercise_sets[0]?.title ?? "Session help",
)

function startAiChat() {
  router.post(aiConversationsPath(), {
    ai_conversation: {
      title: exerciseTitle.value,
      exercise_set_id: props.ai_chat_exercise_set_id,
    },
  })
}

const section = props.tutoring_session.section
const course = section.course!

const breadcrumbs: BreadcrumbItem[] = [
  { title: t("nav.dashboard"), href: dashboardPath() },
  {
    title: t("nav.courses"),
    href: academicPeriodCoursesPath(course.academic_period_id),
  },
  {
    title: course.name,
    href: coursePath(course.id),
  },
  {
    title: section.name,
    href: sectionPath(section.id),
  },
  {
    title: t("sessions.title"),
    href: sectionTutoringSessionsPath(section.id),
  },
  {
    title: props.tutoring_session.date,
    href: tutoringSessionPath(props.tutoring_session.id),
  },
]

function statusVariant(
  status: string,
): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case "completed":
      return "default"
    case "cancelled":
      return "destructive"
    default:
      return "secondary"
  }
}

function deleteSession() {
  if (confirm(t("sessions.confirm_delete"))) {
    router.delete(tutoringSessionPath(props.tutoring_session.id))
  }
}
</script>

<template>
  <Head :title="`${section.name} — ${tutoring_session.date}`" />

  <AppLayout :breadcrumbs="breadcrumbs">
    <div class="flex flex-col gap-6 p-4 md:p-6">
      <div
        class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between"
      >
        <div>
          <h1 class="text-2xl font-semibold tracking-tight">
            <Calendar class="mr-2 inline h-5 w-5" />
            {{ section.name }} — {{ tutoring_session.date }}
          </h1>
          <Badge :variant="statusVariant(tutoring_session.status)" class="mt-2">
            {{ t(`sessions.statuses.${tutoring_session.status}`) }}
          </Badge>
        </div>
        <div v-if="can_manage_session || can_delete_session" class="flex gap-2">
          <Button
            v-if="can_manage_session"
            variant="outline"
            size="sm"
            as-child
          >
            <Link :href="editTutoringSessionPath(tutoring_session.id)">
              {{ t("common.edit") }}
            </Link>
          </Button>
          <Button
            v-if="can_delete_session"
            variant="outline"
            size="sm"
            class="text-destructive"
            @click="deleteSession"
          >
            {{ t("common.delete") }}
          </Button>
        </div>
      </div>

      <Tabs
        v-if="can_take_attendance"
        default-value="attendance"
        class="w-full"
      >
        <TabsList class="grid h-auto w-full max-w-lg grid-cols-3">
          <TabsTrigger value="attendance">
            {{ t("sessions.attendance_tab") }}
          </TabsTrigger>
          <TabsTrigger value="exercises">
            {{ t("sessions.exercises_tab") }}
          </TabsTrigger>
          <TabsTrigger value="students">
            {{ t("sessions.students_tab") }}
          </TabsTrigger>
        </TabsList>

        <TabsContent value="attendance" class="mt-4">
          <Card>
            <CardHeader>
              <CardTitle>{{ t("attendance.title") }}</CardTitle>
            </CardHeader>
            <CardContent>
              <AttendanceGrid
                :tutoring-session-id="tutoring_session.id"
                :enrollments="enrollments"
                :attendances="attendances"
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="exercises" class="mt-4">
          <SessionExercises
            :exercise-sets="exercise_sets"
            :match-type="exercise_match_type"
            :week-number="weekNumber"
          />
        </TabsContent>

        <TabsContent value="students" class="mt-4">
          <SessionStudents
            :enrollments="enrollments"
            :student-summaries="student_summaries"
          />
        </TabsContent>
      </Tabs>

      <div v-else class="flex flex-col gap-6">
        <Card>
          <CardHeader>
            <CardTitle>{{ t("sessions.my_attendance") }}</CardTitle>
          </CardHeader>
          <CardContent>
            <div class="rounded-lg border p-4">
              <p class="text-muted-foreground text-sm">
                {{ t("attendance.my_status") }}
              </p>
              <p class="mt-2 text-base font-medium">
                {{
                  ownAttendance
                    ? t(`attendance.statuses.${ownAttendance.status}`)
                    : t("attendance.not_recorded")
                }}
              </p>
            </div>
          </CardContent>
        </Card>

        <SessionExercises
          :exercise-sets="exercise_sets"
          :match-type="exercise_match_type"
          :week-number="weekNumber"
        />

        <Card v-if="ai_chat_exercise_set_id">
          <CardHeader>
            <CardTitle>
              <MessageCircle class="mr-2 inline h-5 w-5" />
              {{ t("sessions.ai_tutor") }}
            </CardTitle>
            <CardDescription>
              {{ t("sessions.ai_tutor_description") }}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button @click="startAiChat">
              {{ t("sessions.start_ai_chat") }}
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  </AppLayout>
</template>
