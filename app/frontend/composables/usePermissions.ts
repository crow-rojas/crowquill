import { usePage } from "@inertiajs/vue3"
import { computed } from "vue"

import type { Permissions, Role } from "@/types/permissions"

export function usePermissions() {
  const page = usePage()

  const can = computed<Permissions>(
    () =>
      (page.props.auth as { can?: Permissions })?.can ?? {
        manage_sections: false,
        manage_exercises: false,
        manage_academic_periods: false,
        manage_courses: false,
        take_attendance: false,
        view_attendance_statistics: false,
        manage_enrollments: false,
        create_ai_conversations: false,
      },
  )

  const currentRole = computed<Role | null>(
    () =>
      (page.props.auth as { current_role?: Role | null })?.current_role ?? null,
  )

  const isAdmin = computed(() => currentRole.value === "admin")
  const isTutor = computed(() => currentRole.value === "tutor")
  const isTutorado = computed(() => currentRole.value === "tutorado")
  const hasMembership = computed(() => currentRole.value !== null)

  return {
    can,
    currentRole,
    isAdmin,
    isTutor,
    isTutorado,
    hasMembership,
  }
}
