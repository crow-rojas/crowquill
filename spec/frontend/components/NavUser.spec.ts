import { usePage } from "@inertiajs/vue3"
import { mount } from "@vue/test-utils"
import { describe, expect, it, vi } from "vitest"
import { nextTick, reactive } from "vue"

import NavUser from "@/components/NavUser.vue"
import type { Auth } from "@/types"

const pageState = reactive({
  props: {
    auth: buildAuth("Admin User", "admin@crowquill.dev"),
  },
})

vi.mock("@inertiajs/vue3", () => ({
  usePage: vi.fn(),
}))

vi.mock("@/components/ui/dropdown-menu", () => ({
  DropdownMenu: { template: "<div><slot/></div>" },
  DropdownMenuContent: {
    template: "<div><slot/></div>",
    props: ["side", "align", "sideOffset"],
  },
  DropdownMenuTrigger: { template: "<div><slot/></div>", props: ["asChild"] },
}))

vi.mock("@/components/ui/sidebar", () => ({
  SidebarMenu: { template: "<div><slot/></div>" },
  SidebarMenuItem: { template: "<div><slot/></div>" },
  SidebarMenuButton: { template: "<button><slot/></button>", props: ["size"] },
  useSidebar: () => ({ isMobile: false, state: "expanded" }),
}))

vi.mock("@/components/UserInfo.vue", () => ({
  default: {
    template: "<div data-testid='user-name'>{{ user.name }}</div>",
    props: ["user"],
  },
}))

vi.mock("@/components/UserMenuContent.vue", () => ({
  default: {
    template: "<div data-testid='user-menu-content'>menu</div>",
    props: ["auth"],
  },
}))

function buildAuth(name: string, email: string): Auth {
  return {
    user: {
      id: 1,
      name,
      email,
      verified: true,
      created_at: "2026-01-01T00:00:00Z",
      updated_at: "2026-01-01T00:00:00Z",
    },
    session: { id: "session-id" },
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
    dev_user_switch: {
      enabled: true,
      current_user_id: 1,
      current_membership_id: 1,
      users: [
        {
          membership_id: 1,
          id: 1,
          name,
          email,
          role: "admin",
          organization_slug: "pimu-uc",
          organization_name: "PIMU UC",
        },
      ],
    },
  }
}

describe("NavUser", () => {
  it("updates displayed user when Inertia replaces auth props", async () => {
    vi.mocked(usePage).mockReturnValue(pageState as ReturnType<typeof usePage>)

    const wrapper = mount(NavUser)

    expect(wrapper.get('[data-testid="user-name"]').text()).toContain(
      "Admin User",
    )

    pageState.props.auth = buildAuth("Tutor User", "tutor@crowquill.dev")
    await nextTick()

    expect(wrapper.get('[data-testid="user-name"]').text()).toContain(
      "Tutor User",
    )
  })
})
