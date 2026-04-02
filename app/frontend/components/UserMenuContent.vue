<script setup lang="ts">
import { Link, router } from "@inertiajs/vue3"
import { LogOut, Settings, Users } from "lucide-vue-next"
import { computed } from "vue"
import { useI18n } from "vue-i18n"

import UserInfo from "@/components/UserInfo.vue"
import {
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu"
import { devSwitchUserPath, sessionPath, settingsProfilePath } from "@/routes"
import type { Auth } from "@/types"
import type { Role } from "@/types/permissions"

interface Props {
  auth: Auth
}

const { t } = useI18n()
const props = defineProps<Props>()

const roleLabelKey: Record<Role, string> = {
  admin: "nav.dev_switcher.roles.admin",
  tutor: "nav.dev_switcher.roles.tutor",
  tutorado: "nav.dev_switcher.roles.tutorado",
}

const devUserSwitch = computed(() => props.auth.dev_user_switch)
const switchCandidates = computed(() => devUserSwitch.value.users)
const canSwitchUsers = computed(
  () => devUserSwitch.value.enabled && switchCandidates.value.length > 0,
)
const currentSwitchUserId = computed(() => devUserSwitch.value.current_user_id)

const roleLabel = (role: Role) => t(roleLabelKey[role])

const isCurrentSwitchUser = (userId: number) =>
  currentSwitchUserId.value === userId

const handleUserSwitch = (userId: number) => {
  if (!canSwitchUsers.value || isCurrentSwitchUser(userId)) return

  router.post(devSwitchUserPath(), {
    user_id: userId,
    return_to: window.location.pathname + window.location.search,
  })
}

const handleLogout = () => {
  router.flushAll()
}
</script>

<template>
  <DropdownMenuLabel class="p-0 font-normal">
    <div class="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
      <UserInfo :user="auth.user" :show-email="true" />
    </div>
  </DropdownMenuLabel>
  <DropdownMenuSeparator />
  <DropdownMenuGroup>
    <DropdownMenuItem :as-child="true">
      <Link
        class="block w-full"
        :href="settingsProfilePath()"
        prefetch
        as="button"
      >
        <Settings class="mr-2 h-4 w-4" />
        {{ t("nav.settings") }}
      </Link>
    </DropdownMenuItem>
  </DropdownMenuGroup>
  <DropdownMenuSeparator v-if="canSwitchUsers" />
  <DropdownMenuGroup v-if="canSwitchUsers">
    <DropdownMenuLabel
      class="text-muted-foreground px-2 py-1.5 text-xs"
      data-testid="dev-switcher-label"
    >
      {{ t("nav.dev_switcher.label") }}
    </DropdownMenuLabel>
    <div
      class="max-h-64 overflow-y-auto overscroll-contain pr-1"
      data-testid="dev-switcher-list"
    >
      <DropdownMenuItem
        v-for="candidate in switchCandidates"
        :key="candidate.id"
        :as-child="true"
      >
        <button
          type="button"
          class="flex w-full items-center gap-2"
          :data-testid="`switch-user-${candidate.id}`"
          :disabled="isCurrentSwitchUser(candidate.id)"
          @click="handleUserSwitch(candidate.id)"
        >
          <Users class="h-4 w-4 shrink-0" />
          <div class="min-w-0 flex-1 text-left">
            <p class="truncate text-sm">{{ candidate.name }}</p>
            <p class="text-muted-foreground truncate text-xs">
              {{ candidate.email }}
            </p>
          </div>
          <span class="text-muted-foreground text-xs">
            {{ roleLabel(candidate.role) }}
          </span>
          <span
            v-if="isCurrentSwitchUser(candidate.id)"
            class="text-muted-foreground text-xs"
          >
            {{ t("nav.dev_switcher.current") }}
          </span>
        </button>
      </DropdownMenuItem>
    </div>
  </DropdownMenuGroup>
  <DropdownMenuSeparator />
  <DropdownMenuItem :as-child="true">
    <Link
      class="block w-full"
      method="delete"
      :href="sessionPath({ id: auth.session.id })"
      @click="handleLogout"
      as="button"
    >
      <LogOut class="mr-2 h-4 w-4" />
      {{ t("nav.logout") }}
    </Link>
  </DropdownMenuItem>
</template>
