import { mount } from "@vue/test-utils"
import { describe, expect, it } from "vitest"

import FormInput from "@/components/form/FormInput.vue"

describe("FormInput", () => {
  it("renders label and input", () => {
    const wrapper = mount(FormInput, {
      props: { label: "Name", modelValue: "John" },
    })

    expect(wrapper.text()).toContain("Name")
    expect(wrapper.find("input").element.value).toBe("John")
  })

  it("displays error message", () => {
    const wrapper = mount(FormInput, {
      props: { label: "Email", error: "is required", modelValue: "" },
    })

    expect(wrapper.text()).toContain("is required")
  })

  it("shows required asterisk", () => {
    const wrapper = mount(FormInput, {
      props: { label: "Email", required: true, modelValue: "" },
    })

    expect(wrapper.find("span").text()).toBe("*")
  })

  it("emits update:modelValue on input", async () => {
    const wrapper = mount(FormInput, {
      props: { modelValue: "" },
    })

    await wrapper.find("input").setValue("test")
    expect(wrapper.emitted("update:modelValue")).toBeTruthy()
  })
})
