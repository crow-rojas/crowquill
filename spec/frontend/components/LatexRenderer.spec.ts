import { mount } from "@vue/test-utils"
import { describe, expect, it } from "vitest"

import LatexRenderer from "@/components/LatexRenderer.vue"

describe("LatexRenderer", () => {
  it("renders a simple expression", () => {
    const wrapper = mount(LatexRenderer, {
      props: { expression: "x^2" },
    })

    expect(wrapper.find(".katex").exists()).toBe(true)
    expect(wrapper.text()).toContain("x")
  })

  it("renders display mode", () => {
    const wrapper = mount(LatexRenderer, {
      props: { expression: "x^2 + y^2 = z^2", displayMode: true },
    })

    expect(wrapper.find(".katex-display").exists()).toBe(true)
  })

  it("handles invalid LaTeX gracefully", () => {
    const wrapper = mount(LatexRenderer, {
      props: { expression: "\\invalid{}" },
    })

    // Should not crash - katex with throwOnError: false renders error
    expect(wrapper.exists()).toBe(true)
  })
})
