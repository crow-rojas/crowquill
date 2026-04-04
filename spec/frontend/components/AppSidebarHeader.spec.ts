import { usePage } from "@inertiajs/vue3"
import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import AppSidebarHeader from "@/components/AppSidebarHeader.vue"

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
  DropdownMenu: { template: "<div><slot/></div>" },
  DropdownMenuTrigger: {
    template: "<div><slot/></div>",
    props: ["asChild"],
  },
  DropdownMenuContent: {
    template: "<div><slot/></div>",
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

function mockPageWithPeriod(period: PeriodFixture) {
  vi.mocked(usePage).mockReturnValue({
    props: {
      auth: {
        academic_period_context: {
          active: period,
          available: [period],
        },
      },
    },
  } as unknown as ReturnType<typeof usePage>)
}

describe("AppSidebarHeader", () => {
  it("keeps breadcrumbs inside an overflow container", () => {
    mockPageWithPeriod({
      id: 1,
      year: 2026,
      semester: 1,
      name: "1er Semestre 2026",
      start_date: "2026-03-01",
      end_date: "2026-07-01",
      status: "active",
    })

    const wrapper = mount(AppSidebarHeader, {
      props: {
        breadcrumbs: [{ title: "Dashboard", href: "/dashboard" }],
      },
    })

    expect(
      wrapper.get("[data-testid='sidebar-header-breadcrumb-wrap']").classes(),
    ).toContain("overflow-x-auto")
  })

  it("shows canonical year-semester label", () => {
    mockPageWithPeriod({
      id: 2,
      year: 2026,
      semester: 1,
      name: "1er Semestre 2026",
      start_date: "2026-03-10",
      end_date: "2026-07-10",
      status: "active",
    })

    const wrapper = mount(AppSidebarHeader)

    expect(wrapper.get("[data-testid='active-period-label']").text()).toBe(
      "2026-1",
    )
  })

  it("shows second semester label", () => {
    mockPageWithPeriod({
      id: 3,
      year: 2026,
      semester: 2,
      name: null,
      start_date: "2026-08-01",
      end_date: "2026-12-01",
      status: "active",
    })

    const wrapper = mount(AppSidebarHeader)

    expect(wrapper.get("[data-testid='active-period-label']").text()).toBe(
      "2026-2",
    )
  })

  it("shows fallback text when no active period", () => {
    vi.mocked(usePage).mockReturnValue({
      props: {
        auth: {
          academic_period_context: {
            active: null,
            available: [],
          },
        },
      },
    } as unknown as ReturnType<typeof usePage>)

    const wrapper = mount(AppSidebarHeader)

    expect(wrapper.find("[data-testid='active-period-label']").exists()).toBe(
      false,
    )
  })
})
