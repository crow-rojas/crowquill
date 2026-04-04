import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import TutorDashboard from "@/components/dashboard/TutorDashboard.vue"
import type {
  DashboardSection,
  DashboardSession,
  TutorDashboardProps,
} from "@/types/dashboard"

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
  Link: { template: "<a><slot/></a>", props: ["href"] },
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({ t: (key: string) => key }),
}))

vi.mock("@/routes", () => ({
  sectionPath: (id: number) => `/sections/${id}`,
  tutoringSessionPath: (id: number) => `/tutoring_sessions/${id}`,
}))

vi.mock("@/components/ui/card", () => ({
  Card: { template: "<div class='card'><slot/></div>" },
  CardContent: { template: "<div class='card-content'><slot/></div>" },
  CardDescription: {
    template: "<p class='card-description'><slot/></p>",
  },
  CardHeader: { template: "<div class='card-header'><slot/></div>" },
  CardTitle: { template: "<h3 class='card-title'><slot/></h3>" },
}))

function makeSection(
  overrides: Partial<DashboardSection> = {},
): DashboardSection {
  return {
    id: 1,
    name: "Section A",
    schedule: {},
    course: { id: 1, name: "Math 101" },
    enrollments_count: 15,
    ...overrides,
  }
}

function makeSession(
  overrides: Partial<DashboardSession> = {},
): DashboardSession {
  return {
    id: 1,
    date: "2026-04-05",
    status: "scheduled",
    section: { id: 1, name: "Section A" },
    course: { id: 1, name: "Math 101" },
    ...overrides,
  }
}

function defaultProps(
  overrides: Partial<TutorDashboardProps> = {},
): TutorDashboardProps {
  return {
    role: "tutor",
    my_sections: [],
    upcoming_sessions: [],
    next_session: null,
    ...overrides,
  }
}

describe("TutorDashboard", () => {
  it("renders section list with enrollment counts", () => {
    const sections = [
      makeSection({ name: "Group 1", enrollments_count: 10, max_students: 20 }),
      makeSection({ id: 2, name: "Group 2", enrollments_count: 5 }),
    ]

    const wrapper = mount(TutorDashboard, {
      props: defaultProps({ my_sections: sections }),
    })

    const text = wrapper.text()
    expect(text).toContain("Group 1")
    expect(text).toContain("10")
    expect(text).toContain("/ 20")
    expect(text).toContain("Group 2")
    expect(text).toContain("5")
  })

  it("renders upcoming sessions", () => {
    const sessions = [
      makeSession({ course: { id: 1, name: "Algebra" } }),
      makeSession({ id: 2, course: { id: 2, name: "Calculus" } }),
    ]

    const wrapper = mount(TutorDashboard, {
      props: defaultProps({ upcoming_sessions: sessions }),
    })

    expect(wrapper.text()).toContain("Algebra")
    expect(wrapper.text()).toContain("Calculus")
  })

  it("renders empty state when no sections", () => {
    const wrapper = mount(TutorDashboard, {
      props: defaultProps({ my_sections: [], upcoming_sessions: [] }),
    })

    expect(wrapper.text()).toContain("dashboard.no_sections")
    expect(wrapper.text()).toContain("dashboard.no_upcoming")
  })
})
