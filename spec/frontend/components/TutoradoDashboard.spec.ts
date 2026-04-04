import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import TutoradoDashboard from "@/components/dashboard/TutoradoDashboard.vue"
import type {
  DashboardExercise,
  DashboardSection,
  DashboardSession,
  TutoradoDashboardProps,
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
  exerciseSetPath: (id: number) => `/exercise_sets/${id}`,
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

function makeSection(
  overrides: Partial<DashboardSection> = {},
): DashboardSection {
  return {
    id: 1,
    name: "Section A",
    schedule: {},
    course: { id: 1, name: "Math 101" },
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

function makeExercise(
  overrides: Partial<DashboardExercise> = {},
): DashboardExercise {
  return {
    id: 1,
    title: "Practice Set 1",
    week_number: 3,
    course_id: 1,
    ...overrides,
  }
}

function defaultProps(
  overrides: Partial<TutoradoDashboardProps> = {},
): TutoradoDashboardProps {
  return {
    role: "tutorado",
    my_sections: [],
    upcoming_sessions: [],
    recent_exercises: [],
    next_session: null,
    ...overrides,
  }
}

describe("TutoradoDashboard", () => {
  it("renders enrolled sections", () => {
    const sections = [
      makeSection({ name: "Morning Group" }),
      makeSection({ id: 2, name: "Afternoon Group" }),
    ]

    const wrapper = mount(TutoradoDashboard, {
      props: defaultProps({ my_sections: sections }),
    })

    expect(wrapper.text()).toContain("Morning Group")
    expect(wrapper.text()).toContain("Afternoon Group")
  })

  it("renders recent exercises", () => {
    const exercises = [
      makeExercise({ title: "Derivatives Practice" }),
      makeExercise({ id: 2, title: "Integrals Quiz", week_number: 5 }),
    ]

    const wrapper = mount(TutoradoDashboard, {
      props: defaultProps({ recent_exercises: exercises }),
    })

    expect(wrapper.text()).toContain("Derivatives Practice")
    expect(wrapper.text()).toContain("Integrals Quiz")
    expect(wrapper.text()).toContain("5")
  })

  it("renders empty state when no enrollments", () => {
    const wrapper = mount(TutoradoDashboard, {
      props: defaultProps(),
    })

    expect(wrapper.text()).toContain("dashboard.no_sections")
    expect(wrapper.text()).toContain("dashboard.no_upcoming")
    expect(wrapper.text()).toContain("dashboard.no_exercises")
  })

  it("renders upcoming sessions", () => {
    const sessions = [makeSession({ course: { id: 1, name: "Biology 101" } })]

    const wrapper = mount(TutoradoDashboard, {
      props: defaultProps({ upcoming_sessions: sessions }),
    })

    expect(wrapper.text()).toContain("Biology 101")
  })
})
