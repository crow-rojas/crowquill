import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"

import Breadcrumbs from "@/components/Breadcrumbs.vue"

vi.mock("@inertiajs/vue3", () => ({
  Link: {
    template: "<a :href='href'><slot/></a>",
    props: ["href"],
  },
}))

vi.mock("@/components/ui/breadcrumb", () => ({
  Breadcrumb: { template: "<nav><slot/></nav>" },
  BreadcrumbList: { template: "<ol><slot/></ol>" },
  BreadcrumbItem: { template: "<li><slot/></li>" },
  BreadcrumbLink: { template: "<span><slot/></span>", props: ["asChild"] },
  BreadcrumbPage: {
    template: "<span data-testid='breadcrumb-page'><slot/></span>",
  },
  BreadcrumbSeparator: {
    template: "<span data-testid='breadcrumb-separator'>/</span>",
  },
}))

describe("Breadcrumbs", () => {
  it("renders middle breadcrumbs as links and the last breadcrumb as page text", () => {
    const wrapper = mount(Breadcrumbs, {
      props: {
        breadcrumbs: [
          { title: "Dashboard", href: "/dashboard" },
          { title: "Courses", href: "/courses" },
          { title: "Section A", href: "/sections/1" },
        ],
      },
    })

    const links = wrapper.findAll("a")
    expect(links).toHaveLength(2)
    expect(links[0].attributes("href")).toBe("/dashboard")
    expect(links[0].text()).toBe("Dashboard")
    expect(links[1].attributes("href")).toBe("/courses")
    expect(links[1].text()).toBe("Courses")

    expect(
      wrapper.findAll("a").some((link) => link.text() === "Section A"),
    ).toBe(false)
    expect(wrapper.get("[data-testid='breadcrumb-page']").text()).toBe(
      "Section A",
    )
  })

  it("renders a single breadcrumb as non-clickable page text", () => {
    const wrapper = mount(Breadcrumbs, {
      props: {
        breadcrumbs: [{ title: "Only Page", href: "/only-page" }],
      },
    })

    expect(wrapper.findAll("a")).toHaveLength(0)
    expect(wrapper.get("[data-testid='breadcrumb-page']").text()).toBe(
      "Only Page",
    )
  })

  it("falls back to # for non-last breadcrumbs without href", () => {
    const wrapper = mount(Breadcrumbs, {
      props: {
        breadcrumbs: [
          { title: "Dashboard", href: "/dashboard" },
          { title: "Courses" },
          { title: "Current Page", href: "/current-page" },
        ],
      },
    })

    const links = wrapper.findAll("a")
    expect(links).toHaveLength(2)
    expect(links[0].attributes("href")).toBe("/dashboard")
    expect(links[1].attributes("href")).toBe("#")
    expect(links[1].text()).toBe("Courses")
    expect(wrapper.get("[data-testid='breadcrumb-page']").text()).toBe(
      "Current Page",
    )
  })
})
