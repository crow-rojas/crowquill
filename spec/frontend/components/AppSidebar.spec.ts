import { usePage } from "@inertiajs/vue3"
import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import AppSidebar from "@/components/AppSidebar.vue"

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
  Link: { template: "<a :href='href'><slot/></a>", props: ["href"] },
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({ t: (key: string) => key }),
}))

vi.mock("@/routes", () => ({
  academicPeriodCoursesPath: (id: number) => `/academic_periods/${id}/courses`,
  academicPeriodsPath: () => "/academic_periods",
  aiConversationsPath: () => "/ai_conversations",
  dashboardPath: () => "/dashboard",
}))

vi.mock("@/components/NavMain.vue", () => ({
  default: {
    template: "<pre data-testid='nav-items'>{{ JSON.stringify(items) }}</pre>",
    props: ["items"],
  },
}))

vi.mock("@/components/NavUser.vue", () => ({
  default: { template: "<div data-testid='nav-user' />" },
}))

vi.mock("@/components/AppLogo.vue", () => ({
  default: { template: "<div data-testid='app-logo' />" },
}))

vi.mock("@/components/ui/sidebar", () => ({
  Sidebar: {
    template: "<aside><slot/></aside>",
    props: ["collapsible", "variant"],
  },
  SidebarContent: { template: "<div><slot/></div>" },
  SidebarFooter: { template: "<footer><slot/></footer>" },
  SidebarHeader: { template: "<header><slot/></header>" },
  SidebarMenu: { template: "<ul><slot/></ul>" },
  SidebarMenuButton: {
    template: "<button><slot/></button>",
    props: ["size", "asChild"],
  },
  SidebarMenuItem: { template: "<li><slot/></li>" },
}))

type NavNode = {
  title: string
  href?: string
  items?: NavNode[]
}

function mockPageAuth(activePeriodId: number | null) {
  vi.mocked(usePage).mockReturnValue({
    props: {
      auth: {
        academic_period_context: {
          active: activePeriodId
            ? {
                id: activePeriodId,
                year: 2026,
                semester: 1,
                name: null,
                start_date: "2026-03-01",
                end_date: "2026-07-01",
                status: "active",
              }
            : null,
          available: [],
        },
      },
    },
  } as unknown as ReturnType<typeof usePage>)
}

function mountAndReadItems(): NavNode[] {
  const wrapper = mount(AppSidebar)
  const text = wrapper.get("[data-testid='nav-items']").text()
  return JSON.parse(text) as NavNode[]
}

describe("AppSidebar", () => {
  it("shows Courses link pointing to active period courses", () => {
    mockPageAuth(10)

    const items = mountAndReadItems()

    const courses = items.find((item) => item.title === "nav.courses")
    expect(courses).toBeDefined()
    expect(courses?.href).toBe("/academic_periods/10/courses")
  })

  it("falls back to academic periods path when no active period", () => {
    mockPageAuth(null)

    const items = mountAndReadItems()

    const courses = items.find((item) => item.title === "nav.courses")
    expect(courses).toBeDefined()
    expect(courses?.href).toBe("/academic_periods")
  })

  it("does not show academic management, teaching, or learning groups", () => {
    mockPageAuth(10)

    const items = mountAndReadItems()

    const titles = items.map((item) => item.title)
    expect(titles).not.toContain("nav.academic_management")
    expect(titles).not.toContain("nav.teaching")
    expect(titles).not.toContain("nav.learning")
  })

  it("always includes AI chat item", () => {
    mockPageAuth(5)

    const items = mountAndReadItems()

    expect(
      items.some(
        (item) =>
          item.title === "nav.ai_chat" && item.href === "/ai_conversations",
      ),
    ).toBe(true)
  })

  it("renders Dashboard, Courses, and AI Chat in order", () => {
    mockPageAuth(1)

    const items = mountAndReadItems()

    expect(items.map((i) => i.title)).toEqual([
      "nav.dashboard",
      "nav.courses",
      "nav.ai_chat",
    ])
  })
})
