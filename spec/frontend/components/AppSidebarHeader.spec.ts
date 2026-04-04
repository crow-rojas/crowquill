import { usePage } from "@inertiajs/vue3"
import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import AppSidebarHeader from "@/components/AppSidebarHeader.vue"
import { usePermissions } from "@/composables/usePermissions"

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
  Link: {
    template: "<a :href='href'><slot/></a>",
    props: ["href"],
  },
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({ t: (key: string) => key }),
}))

vi.mock("@/composables/usePermissions", () => ({
  usePermissions: vi.fn(),
}))

vi.mock("@/routes", () => ({
  academicPeriodPath: (id: number) => `/academic_periods/${id}`,
  academicPeriodsPath: () => "/academic_periods",
}))

vi.mock("@/components/Breadcrumbs.vue", () => ({
  default: {
    template: "<nav data-testid='breadcrumbs' />",
    props: ["breadcrumbs"],
  },
}))

vi.mock("@/components/ui/button", () => ({
  Button: {
    template: "<button><slot/></button>",
    props: ["variant", "size"],
  },
}))

vi.mock("@/components/ui/dropdown-menu", () => ({
  DropdownMenu: { template: "<div data-testid='dropdown-menu'><slot/></div>" },
  DropdownMenuTrigger: {
    template: "<div><slot/></div>",
    props: ["asChild"],
  },
  DropdownMenuContent: {
    template: "<div data-testid='dropdown-content'><slot/></div>",
    props: ["align"],
  },
  DropdownMenuItem: {
    template: "<div><slot/></div>",
    props: ["asChild"],
  },
  DropdownMenuLabel: { template: "<div><slot/></div>" },
  DropdownMenuSeparator: { template: "<hr />" },
}))

vi.mock("@/components/ui/sidebar", () => ({
  SidebarTrigger: { template: "<button data-testid='sidebar-trigger' />" },
}))

type PeriodFixture = {
  id: number
  year: number
  semester: 1 | 2
  name: string | null
  start_date: string
  end_date: string
  status: "draft" | "active" | "archived"
}

function mockPermissions(isAdmin: boolean) {
  vi.mocked(usePermissions).mockReturnValue({
    can: {
      value: {
        manage_sections: false,
        manage_exercises: false,
        manage_academic_periods: isAdmin,
        manage_courses: false,
        take_attendance: false,
        view_attendance_statistics: false,
        manage_enrollments: false,
        create_ai_conversations: true,
      },
    },
  } as ReturnType<typeof usePermissions>)
}

function mockPageWithPeriod(period: PeriodFixture | null) {
  vi.mocked(usePage).mockReturnValue({
    props: {
      auth: {
        academic_period_context: {
          active: period,
          available: period ? [period] : [],
        },
      },
    },
  } as unknown as ReturnType<typeof usePage>)
}

const activePeriod: PeriodFixture = {
  id: 1,
  year: 2026,
  semester: 1,
  name: "1er Semestre 2026",
  start_date: "2026-03-01",
  end_date: "2026-07-01",
  status: "active",
}

describe("AppSidebarHeader", () => {
  it("admin sees dropdown with period switcher", () => {
    mockPermissions(true)
    mockPageWithPeriod(activePeriod)

    const wrapper = mount(AppSidebarHeader)

    expect(wrapper.find("[data-testid='dropdown-menu']").exists()).toBe(true)
    expect(wrapper.get("[data-testid='active-period-label']").text()).toBe(
      "2026-1",
    )
  })

  it("admin dropdown includes manage periods link", () => {
    mockPermissions(true)
    mockPageWithPeriod(activePeriod)

    const wrapper = mount(AppSidebarHeader)

    const manageLink = wrapper
      .findAll("a")
      .find((a) => a.attributes("href") === "/academic_periods")
    expect(manageLink).toBeDefined()
    expect(manageLink?.text()).toContain("nav.manage_periods")
  })

  it("non-admin sees read-only period badge", () => {
    mockPermissions(false)
    mockPageWithPeriod(activePeriod)

    const wrapper = mount(AppSidebarHeader)

    expect(wrapper.find("[data-testid='dropdown-menu']").exists()).toBe(false)
    const badge = wrapper.get("[data-testid='period-badge-readonly']")
    expect(badge.text()).toContain("2026-1")
  })

  it("shows nothing when no academic periods exist", () => {
    mockPermissions(true)
    mockPageWithPeriod(null)

    const wrapper = mount(AppSidebarHeader)

    expect(wrapper.find("[data-testid='dropdown-menu']").exists()).toBe(false)
    expect(wrapper.find("[data-testid='period-badge-readonly']").exists()).toBe(
      false,
    )
  })

  it("non-admin sees nothing when no active period", () => {
    mockPermissions(false)
    vi.mocked(usePage).mockReturnValue({
      props: {
        auth: {
          academic_period_context: {
            active: null,
            available: [activePeriod],
          },
        },
      },
    } as unknown as ReturnType<typeof usePage>)

    const wrapper = mount(AppSidebarHeader)

    expect(wrapper.find("[data-testid='period-badge-readonly']").exists()).toBe(
      false,
    )
  })

  it("keeps breadcrumbs inside an overflow container", () => {
    mockPermissions(false)
    mockPageWithPeriod(activePeriod)

    const wrapper = mount(AppSidebarHeader, {
      props: {
        breadcrumbs: [{ title: "Dashboard", href: "/dashboard" }],
      },
    })

    expect(
      wrapper.get("[data-testid='sidebar-header-breadcrumb-wrap']").classes(),
    ).toContain("overflow-x-auto")
  })
})
