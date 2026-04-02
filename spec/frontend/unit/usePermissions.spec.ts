import { usePage } from "@inertiajs/vue3"
import { describe, expect, it, vi } from "vitest"

import { usePermissions } from "@/composables/usePermissions"
import type { Permissions, Role } from "@/types/permissions"

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
}))

function mockPageProps(role: Role | null, can: Partial<Permissions> = {}) {
  const defaults: Permissions = {
    manage_sections: false,
    manage_exercises: false,
    manage_academic_periods: false,
    manage_courses: false,
    take_attendance: false,
    view_attendance_statistics: false,
    manage_enrollments: false,
    create_ai_conversations: false,
  }

  vi.mocked(usePage).mockReturnValue({
    props: {
      auth: {
        current_role: role,
        can: { ...defaults, ...can },
      },
    },
  } as ReturnType<typeof usePage>)
}

describe("usePermissions", () => {
  it("returns correct role for admin", () => {
    mockPageProps("admin", { manage_sections: true })
    const { currentRole, isAdmin, isTutor, isTutorado } = usePermissions()

    expect(currentRole.value).toBe("admin")
    expect(isAdmin.value).toBe(true)
    expect(isTutor.value).toBe(false)
    expect(isTutorado.value).toBe(false)
  })

  it("returns correct role for tutor", () => {
    mockPageProps("tutor", { take_attendance: true })
    const { currentRole, isAdmin, isTutor } = usePermissions()

    expect(currentRole.value).toBe("tutor")
    expect(isAdmin.value).toBe(false)
    expect(isTutor.value).toBe(true)
  })

  it("returns correct role for tutorado", () => {
    mockPageProps("tutorado")
    const { currentRole, isTutorado, hasMembership } = usePermissions()

    expect(currentRole.value).toBe("tutorado")
    expect(isTutorado.value).toBe(true)
    expect(hasMembership.value).toBe(true)
  })

  it("returns hasMembership false when no role", () => {
    mockPageProps(null)
    const { hasMembership, currentRole } = usePermissions()

    expect(hasMembership.value).toBe(false)
    expect(currentRole.value).toBeNull()
  })

  it("returns permissions from page props", () => {
    mockPageProps("admin", {
      manage_sections: true,
      manage_exercises: true,
      take_attendance: true,
      view_attendance_statistics: true,
    })
    const { can } = usePermissions()

    expect(can.value.manage_sections).toBe(true)
    expect(can.value.manage_exercises).toBe(true)
    expect(can.value.take_attendance).toBe(true)
    expect(can.value.view_attendance_statistics).toBe(true)
    expect(can.value.manage_enrollments).toBe(false)
  })

  it("returns default false permissions when auth props are missing", () => {
    vi.mocked(usePage).mockReturnValue({
      props: { auth: {} },
    } as ReturnType<typeof usePage>)

    const { can, hasMembership } = usePermissions()

    expect(can.value.manage_sections).toBe(false)
    expect(hasMembership.value).toBe(false)
  })
})
