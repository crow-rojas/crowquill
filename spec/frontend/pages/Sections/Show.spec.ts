import { mount } from "@vue/test-utils"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { usePermissions } from "@/composables/usePermissions"
import SectionsShow from "@/pages/Sections/Show.vue"

vi.mock("@inertiajs/vue3", () => ({
  Head: { template: "<div><slot/></div>", props: ["title"] },
  Link: { template: '<a :href="href"><slot/></a>', props: ["href"] },
  router: { delete: vi.fn() },
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({
    t: (key: string) => {
      const translations: Record<string, string> = {
        "nav.dashboard": "Dashboard",
        "academic_periods.title": "Academic Periods",
        "sections.tutor": "Tutor",
        "sections.max_students": "Max students",
        "sections.schedule": "Schedule",
        "sections.no_schedule": "No schedule defined",
        "sections.time_label": "Time",
        "sections.room_label": "Room",
        "sections.unspecified_day": "Day not specified",
        "sections.unspecified_time": "Time not specified",
        "sections.days.monday": "Monday",
        "sections.days.tuesday": "Tuesday",
        "sections.days.thursday": "Thursday",
        "sessions.title": "Tutoring Sessions",
        "sessions.new": "New Session",
        "enrollment.title": "Enrollments",
      }

      return translations[key] ?? key
    },
  }),
}))

vi.mock("@/composables/usePermissions", () => ({
  usePermissions: vi.fn(),
}))

vi.mock("@/routes", () => ({
  academicPeriodCoursesPath: (id: number) => `/academic_periods/${id}/courses`,
  coursePath: (id: number) => `/courses/${id}`,
  dashboardPath: () => "/dashboard",
  editSectionPath: (id: number) => `/sections/${id}/edit`,
  newSectionTutoringSessionPath: (id: number) =>
    `/sections/${id}/tutoring_sessions/new`,
  sectionEnrollmentsPath: (id: number) => `/sections/${id}/enrollments`,
  sectionPath: (id: number) => `/sections/${id}`,
  sectionTutoringSessionsPath: (id: number) =>
    `/sections/${id}/tutoring_sessions`,
}))

vi.mock("@/layouts/AppLayout.vue", () => ({
  default: { template: "<div><slot/></div>", props: ["breadcrumbs"] },
}))

vi.mock("@/components/CommitmentDialog.vue", () => ({
  default: {
    template: "<div data-testid='commitment-dialog' />",
    props: ["sectionId", "disabled"],
  },
}))

vi.mock("@/components/ui/button", () => ({
  Button: {
    template: "<button><slot/></button>",
    props: ["variant", "size", "asChild", "class"],
  },
}))

vi.mock("@/components/ui/card", () => ({
  Card: { template: "<div><slot/></div>" },
  CardContent: { template: "<div><slot/></div>" },
  CardHeader: { template: "<div><slot/></div>" },
  CardTitle: { template: "<h3><slot/></h3>" },
}))

function makeSection(overrides: Record<string, unknown> = {}) {
  return {
    id: 1,
    name: "Section A",
    schedule: {},
    max_students: 20,
    course_id: 10,
    tutor_id: 2,
    tutor: { id: 2, name: "Tutor A", email: "tutor@example.com" },
    course: {
      id: 10,
      name: "Math 101",
      description: "",
      academic_period_id: 5,
      created_at: "2026-01-01",
      updated_at: "2026-01-01",
    },
    created_at: "2026-01-01",
    updated_at: "2026-01-01",
    ...overrides,
  }
}

function renderPage(overrides: Record<string, unknown> = {}) {
  return mount(SectionsShow, {
    props: {
      section: makeSection(),
      enrollments_count: 0,
      current_enrollment: null,
      is_full: false,
      can_view_enrollments: false,
      can_view_sessions: false,
      can_create_session: false,
      ...overrides,
    },
  })
}

describe("Sections/Show", () => {
  beforeEach(() => {
    vi.mocked(usePermissions).mockReturnValue({
      can: {
        manage_sections: false,
      },
      hasRole: vi.fn(),
    } as unknown as ReturnType<typeof usePermissions>)
  })

  it("renders flat schedule with day, time range, and room", () => {
    const wrapper = renderPage({
      section: makeSection({
        schedule: {
          day: "monday",
          start_time: "09:00",
          end_time: "10:30",
          room: "A-101",
        },
      }),
    })

    expect(wrapper.text()).toContain("Monday")
    expect(wrapper.text()).toContain("09:00 - 10:30")
    expect(wrapper.text()).toContain("A-101")
  })

  it("renders mixed day schedule entries and fallback labels", () => {
    const wrapper = renderPage({
      section: makeSection({
        schedule: {
          tuesday: "18:00",
          thursday: { start_time: "10:00", end_time: "11:30" },
          special_day: null,
        },
      }),
    })

    const text = wrapper.text()
    expect(text).toContain("Tuesday")
    expect(text).toContain("18:00")
    expect(text).toContain("Thursday")
    expect(text).toContain("10:00 - 11:30")
    expect(text).toContain("Special Day")
    expect(text).toContain("Time not specified")
  })

  it("shows no-schedule message when schedule is empty", () => {
    const wrapper = renderPage({ section: makeSection({ schedule: {} }) })

    expect(wrapper.text()).toContain("No schedule defined")
  })

  it("shows session list and create buttons when capabilities are enabled", () => {
    const wrapper = renderPage({
      can_view_sessions: true,
      can_create_session: true,
    })

    const links = wrapper.findAll("a")
    const hrefs = links.map((link) => link.attributes("href"))

    expect(hrefs).toContain("/sections/1/tutoring_sessions")
    expect(hrefs).toContain("/sections/1/tutoring_sessions/new")
    expect(wrapper.text()).toContain("Tutoring Sessions")
    expect(wrapper.text()).toContain("New Session")
  })

  it("hides session buttons when capabilities are disabled", () => {
    const wrapper = renderPage({
      can_view_sessions: false,
      can_create_session: false,
    })

    const links = wrapper.findAll("a")
    const hrefs = links.map((link) => link.attributes("href"))

    expect(hrefs).not.toContain("/sections/1/tutoring_sessions")
    expect(hrefs).not.toContain("/sections/1/tutoring_sessions/new")
  })
})
