import { usePage } from "@inertiajs/vue3"
import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"
import { defineComponent, markRaw } from "vue"

import NavMain from "@/components/NavMain.vue"

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
  Link: { template: "<a><slot/></a>", props: ["href"] },
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({ t: (key: string) => key }),
}))

// Stub sidebar UI components to avoid complex setup
vi.mock("@/components/ui/sidebar", () => ({
  SidebarGroup: { template: "<div><slot/></div>" },
  SidebarGroupLabel: { template: "<span><slot/></span>" },
  SidebarMenu: { template: "<ul><slot/></ul>" },
  SidebarMenuButton: {
    template: '<li :data-active="isActive"><slot/></li>',
    props: ["asChild", "isActive", "tooltip"],
  },
  SidebarMenuItem: { template: "<div><slot/></div>" },
}))

function mockPage(url: string) {
  vi.mocked(usePage).mockReturnValue({
    url,
    props: {},
  } as ReturnType<typeof usePage>)
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const fakeIcon = markRaw(defineComponent({ template: "<svg/>" })) as any

describe("NavMain", () => {
  it("marks item active when page.url matches href exactly", () => {
    mockPage("/dashboard")
    const wrapper = mount(NavMain, {
      props: {
        items: [{ title: "Dashboard", href: "/dashboard", icon: fakeIcon }],
      },
    })

    const button = wrapper.find("[data-active]")
    expect(button.attributes("data-active")).toBe("true")
  })

  it("marks item active when page.url is a sub-path of href", () => {
    mockPage("/academic_periods/1/courses")
    const wrapper = mount(NavMain, {
      props: {
        items: [
          {
            title: "Periods",
            href: "/academic_periods",
            icon: fakeIcon,
          },
        ],
      },
    })

    const button = wrapper.find("[data-active]")
    expect(button.attributes("data-active")).toBe("true")
  })

  it("does NOT mark item active when page.url does not match", () => {
    mockPage("/dashboard")
    const wrapper = mount(NavMain, {
      props: {
        items: [
          {
            title: "Periods",
            href: "/academic_periods",
            icon: fakeIcon,
          },
        ],
      },
    })

    const button = wrapper.find("[data-active]")
    expect(button.attributes("data-active")).toBe("false")
  })

  it("strips query params before matching", () => {
    mockPage("/academic_periods?page=2")
    const wrapper = mount(NavMain, {
      props: {
        items: [
          {
            title: "Periods",
            href: "/academic_periods",
            icon: fakeIcon,
          },
        ],
      },
    })

    const button = wrapper.find("[data-active]")
    expect(button.attributes("data-active")).toBe("true")
  })

  it("root path / only matches exactly /", () => {
    mockPage("/dashboard")
    const wrapper = mount(NavMain, {
      props: {
        items: [{ title: "Home", href: "/", icon: fakeIcon }],
      },
    })

    const button = wrapper.find("[data-active]")
    expect(button.attributes("data-active")).toBe("false")
  })

  it("root path / matches when page.url is /", () => {
    mockPage("/")
    const wrapper = mount(NavMain, {
      props: {
        items: [{ title: "Home", href: "/", icon: fakeIcon }],
      },
    })

    const button = wrapper.find("[data-active]")
    expect(button.attributes("data-active")).toBe("true")
  })
})
