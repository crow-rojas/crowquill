import { mount } from "@vue/test-utils"
import { describe, expect, it } from "vitest"
import { createI18n } from "vue-i18n"

import ExerciseEditor from "@/components/ExerciseEditor.vue"

const i18n = createI18n({
  legacy: false,
  locale: "en",
  messages: {
    en: {
      exercises: {
        editor: "Editor",
        preview: "Preview",
      },
    },
  },
})

describe("ExerciseEditor", () => {
  it("renders editor and preview labels on desktop", () => {
    const wrapper = mount(ExerciseEditor, {
      props: { modelValue: "Hello **world**" },
      global: { plugins: [i18n] },
    })

    expect(wrapper.text()).toContain("Editor")
    expect(wrapper.text()).toContain("Preview")
  })

  it("renders textarea with modelValue", () => {
    const wrapper = mount(ExerciseEditor, {
      props: { modelValue: "Test content" },
      global: { plugins: [i18n] },
    })

    const textarea = wrapper.find("textarea")
    expect(textarea.exists()).toBe(true)
    expect(textarea.element.value).toBe("Test content")
  })

  it("emits update:modelValue on input", async () => {
    const wrapper = mount(ExerciseEditor, {
      props: { modelValue: "" },
      global: { plugins: [i18n] },
    })

    const textarea = wrapper.find("textarea")
    await textarea.setValue("new content")
    expect(wrapper.emitted("update:modelValue")).toBeTruthy()
  })
})
