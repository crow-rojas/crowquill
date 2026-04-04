import { usePage } from "@inertiajs/vue3"
import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import AppSidebar from "@/components/AppSidebar.vue"
import { usePermissions } from "@/composables/usePermissions"

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
  Link: { template: "<a :href='href'><slot/></a>", props: ["href"] },
}))

vi.mock("@/composables/usePermissions", () => ({
  usePermissions: vi.fn(),
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({ t: (key: string) => key }),
}))

vi.mock("@/routes", () => ({
  academicPeriodPath: (id: number) => `/academic_periods/${id}`,
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

function mockPermissions(options: {
  manageAcademicPeriods: boolean
  isTutor: boolean
  isTutorado: boolean
}) {
  vi.mocked(usePermissions).mockReturnValue({
    can: {
      value: {
        manage_sections: false,
        manage_exercises: false,
        manage_academic_periods: options.manageAcademicPeriods,
        manage_courses: false,
        take_attendance: false,
        view_attendance_statistics: false,
        manage_enrollments: false,
        create_ai_conversations: true,
      },
    },
    isTutor: { value: options.isTutor },
    isTutorado: { value: options.isTutorado },
  } as ReturnType<typeof usePermissions>)
}

function mountAndReadItems(): NavNode[] {
  const wrapper = mount(AppSidebar)
  const text = wrapper.get("[data-testid='nav-items']").text()
  return JSON.parse(text) as NavNode[]
}

describe("AppSidebar", () => {
  it("shows academic management items for admins", () => {
    mockPageAuth(10)
    mockPermissions({
      manageAcademicPeriods: true,
      isTutor: false,
      isTutorado: false,
    })

    const items = mountAndReadItems()

    const academicGroup = items.find(
      (item) => item.title === "nav.academic_management",
    )
    expect(academicGroup).toBeDefined()
    expect(
      academicGroup?.items?.some((item) => item.title === "nav.current_period"),
    ).toBe(true)
    expect(
      academicGroup?.items?.some(
        (item) =>
          item.title === "nav.academic_periods" &&
          item.href === "/academic_periods",
      ),
    ).toBe(true)
  })

  it("shows learning group for tutorados and uses fallback href when no active period", () => {
    mockPageAuth(null)
    mockPermissions({
      manageAcademicPeriods: false,
      isTutor: false,
      isTutorado: true,
    })

    const items = mountAndReadItems()

    const learningGroup = items.find((item) => item.title === "nav.learning")
    expect(learningGroup).toBeDefined()
    expect(learningGroup?.items).toEqual([
      {
        title: "nav.current_period",
        href: "/academic_periods",
      },
    ])
  })

  it("always includes AI chat item for all roles", () => {
    const scenarios = [
      {
        manageAcademicPeriods: true,
        isTutor: false,
        isTutorado: false,
      },
      {
        manageAcademicPeriods: false,
        isTutor: true,
        isTutorado: false,
      },
      {
        manageAcademicPeriods: false,
        isTutor: false,
        isTutorado: true,
      },
    ]

    for (const scenario of scenarios) {
      mockPageAuth(5)
      mockPermissions(scenario)
      const items = mountAndReadItems()

      expect(
        items.some(
          (item) =>
            item.title === "nav.ai_chat" && item.href === "/ai_conversations",
        ),
      ).toBe(true)
    }
  })
})
