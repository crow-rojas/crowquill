import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import AdminDashboard from "@/components/dashboard/AdminDashboard.vue"
import type { AdminDashboardProps, DashboardSession } from "@/types/dashboard"

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
  Link: { template: "<a><slot/></a>", props: ["href"] },
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({ t: (key: string) => key }),
}))

vi.mock("@/routes", () => ({
  tutoringSessionPath: (id: number) => `/tutoring_sessions/${id}`,
}))

vi.mock("@/components/ui/card", () => ({
  Card: { template: "<div class='card'><slot/></div>" },
  CardContent: { template: "<div class='card-content'><slot/></div>" },
  CardDescription: {
    template: "<p class='card-description'><slot/></p>",
  },
  CardHeader: { template: "<div class='card-header'><slot/></div>" },
  CardTitle: {
    template: "<h3 class='card-title'><slot/></h3>",
    props: ["class"],
  },
}))

function makeSession(
  overrides: Partial<DashboardSession> = {},
): DashboardSession {
  return {
    id: 1,
    date: "2026-04-01",
    status: "scheduled",
    section: { id: 1, name: "Section A" },
    course: { id: 1, name: "Math 101" },
    ...overrides,
  }
}

function defaultProps(
  overrides: Partial<AdminDashboardProps> = {},
): AdminDashboardProps {
  return {
    role: "admin",
    active_period: {
      id: 1,
      year: 2026,
      semester: 1,
      name: "Spring 2026",
      start_date: "2026-01-15",
      end_date: "2026-06-15",
      status: "active",
    },
    total_students: 42,
    total_tutors: 8,
    active_sections: 12,
    recent_sessions: [],
    ...overrides,
  }
}

describe("AdminDashboard", () => {
  it("renders stat cards with provided counts", () => {
    const wrapper = mount(AdminDashboard, {
      props: defaultProps(),
    })

    const text = wrapper.text()
    expect(text).toContain("42")
    expect(text).toContain("8")
    expect(text).toContain("12")
  })

  it("renders period name when active_period is provided", () => {
    const wrapper = mount(AdminDashboard, {
      props: defaultProps(),
    })

    expect(wrapper.text()).toContain("2026-1")
  })

  it("renders no-data state when active_period is null", () => {
    const wrapper = mount(AdminDashboard, {
      props: defaultProps({ active_period: null }),
    })

    expect(wrapper.text()).toContain("dashboard.no_active_period")
  })

  it("renders recent sessions list", () => {
    const sessions = [
      makeSession({ id: 1, course: { id: 1, name: "Math 101" } }),
      makeSession({
        id: 2,
        status: "completed",
        course: { id: 2, name: "Physics 201" },
      }),
    ]

    const wrapper = mount(AdminDashboard, {
      props: defaultProps({ recent_sessions: sessions }),
    })

    expect(wrapper.text()).toContain("Math 101")
    expect(wrapper.text()).toContain("Physics 201")
  })

  it("renders empty state when no recent sessions", () => {
    const wrapper = mount(AdminDashboard, {
      props: defaultProps({ recent_sessions: [] }),
    })

    expect(wrapper.text()).toContain("dashboard.no_upcoming")
  })
})
