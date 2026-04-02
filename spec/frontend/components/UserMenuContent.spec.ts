import { mount } from "@vue/test-utils"
import { beforeEach, describe, expect, it, vi } from "vitest"

import UserMenuContent from "@/components/UserMenuContent.vue"
import type { Auth, DevUserSwitch } from "@/types"

const inertiaMocks = vi.hoisted(() => ({
  post: vi.fn(),
  flushAll: vi.fn(),
}))

vi.mock("@inertiajs/vue3", () => ({
  Link: {
    template: "<a><slot/></a>",
    props: ["href", "method", "as", "prefetch"],
  },
  router: {
    post: inertiaMocks.post,
    flushAll: inertiaMocks.flushAll,
  },
}))

vi.mock("vue-i18n", () => ({
  useI18n: () => ({ t: (key: string) => key }),
}))

vi.mock("@/routes", () => ({
  devSwitchUserPath: () => "/dev/switch_user",
  sessionPath: ({ id }: { id: string }) => `/sessions/${id}`,
  settingsProfilePath: () => "/settings/profile",
}))

vi.mock("@/components/UserInfo.vue", () => ({
  default: {
    template: "<div class='user-info' />",
    props: ["user", "showEmail"],
  },
}))

vi.mock("@/components/ui/dropdown-menu", () => ({
  DropdownMenuGroup: { template: "<div><slot/></div>" },
  DropdownMenuItem: {
    template: "<div><slot/></div>",
    props: ["asChild"],
  },
  DropdownMenuLabel: {
    template: "<div v-bind='$attrs'><slot/></div>",
  },
  DropdownMenuSeparator: { template: "<hr />" },
}))

function makeDevUserSwitch(
  overrides: Partial<DevUserSwitch> = {},
): DevUserSwitch {
  return Object.assign(
    {
      enabled: false,
      current_user_id: 1,
      users: [] as DevUserSwitch["users"],
    },
    overrides,
  )
}

function makeAuth(overrides: Partial<Auth> = {}): Auth {
  const devUserSwitch = makeDevUserSwitch(overrides.dev_user_switch)
  const baseAuth: Auth = {
    user: {
      id: 1,
      name: "Admin User",
      email: "admin@crowquill.dev",
      verified: true,
      created_at: "2026-01-01T00:00:00Z",
      updated_at: "2026-01-01T00:00:00Z",
    },
    session: { id: "1" },
    membership: { id: 1, role: "admin" },
    current_role: "admin",
    can: {
      manage_sections: true,
      manage_exercises: true,
      manage_academic_periods: true,
      manage_courses: true,
      take_attendance: true,
      view_attendance_statistics: true,
      manage_enrollments: true,
      create_ai_conversations: true,
    },
    dev_user_switch: devUserSwitch,
  }

  return Object.assign(baseAuth, overrides, { dev_user_switch: devUserSwitch })
}

describe("UserMenuContent", () => {
  beforeEach(() => {
    inertiaMocks.post.mockReset()
    inertiaMocks.flushAll.mockReset()
    window.history.replaceState({}, "", "/")
  })

  it("hides dev switcher section when feature is disabled", () => {
    const wrapper = mount(UserMenuContent, {
      props: {
        auth: makeAuth({
          dev_user_switch: makeDevUserSwitch({ enabled: false }),
        }),
      },
    })

    expect(wrapper.find('[data-testid="dev-switcher-label"]').exists()).toBe(
      false,
    )
  })

  it("renders switch candidates and marks current user", () => {
    const wrapper = mount(UserMenuContent, {
      props: {
        auth: makeAuth({
          dev_user_switch: makeDevUserSwitch({
            enabled: true,
            current_user_id: 1,
            users: [
              {
                id: 1,
                name: "Admin User",
                email: "admin@crowquill.dev",
                role: "admin",
              },
              {
                id: 2,
                name: "Tutor One",
                email: "tutor1@crowquill.dev",
                role: "tutor",
              },
            ],
          }),
        }),
      },
    })

    expect(wrapper.find('[data-testid="dev-switcher-label"]').exists()).toBe(
      true,
    )
    const switcherList = wrapper.get('[data-testid="dev-switcher-list"]')
    expect(switcherList.classes()).toContain("max-h-64")
    expect(switcherList.classes()).toContain("overflow-y-auto")
    expect(wrapper.text()).toContain("Admin User")
    expect(wrapper.text()).toContain("Tutor One")
    expect(wrapper.text()).toContain("nav.dev_switcher.current")

    const currentUserButton = wrapper.get('[data-testid="switch-user-1"]')
    expect((currentUserButton.element as HTMLButtonElement).disabled).toBe(true)
  })

  it("posts switch request with selected user and current location", async () => {
    window.history.replaceState({}, "", "/dashboard?tab=overview")

    const wrapper = mount(UserMenuContent, {
      props: {
        auth: makeAuth({
          dev_user_switch: makeDevUserSwitch({
            enabled: true,
            current_user_id: 1,
            users: [
              {
                id: 1,
                name: "Admin User",
                email: "admin@crowquill.dev",
                role: "admin",
              },
              {
                id: 3,
                name: "Student Two",
                email: "alumno2@crowquill.dev",
                role: "tutorado",
              },
            ],
          }),
        }),
      },
    })

    await wrapper.get('[data-testid="switch-user-3"]').trigger("click")

    expect(inertiaMocks.post).toHaveBeenCalledWith("/dev/switch_user", {
      user_id: 3,
      return_to: "/dashboard?tab=overview",
    })
  })
})
