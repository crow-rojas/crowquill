import type { LucideIcon } from "lucide-vue-next"

import type { Membership, Permissions, Role } from "./permissions"

export interface DevSwitchUser {
  id: number
  name: string
  email: string
  role: Role
}

export interface DevUserSwitch {
  enabled: boolean
  current_user_id: number | null
  users: DevSwitchUser[]
}

export interface Auth {
  user: User
  session: Pick<Session, "id">
  membership: Membership | null
  current_role: Role | null
  can: Permissions
  dev_user_switch: DevUserSwitch
}

export interface BreadcrumbItem {
  title: string
  href: string
}

export interface NavItem {
  title: string
  href?: string
  icon?: LucideIcon
  isActive?: boolean
  items?: NavItem[]
  defaultOpen?: boolean
}

export interface FlashData {
  alert?: string
  notice?: string
}

export interface SharedData {
  auth: Auth
}

export interface User {
  id: number
  name: string
  email: string
  avatar?: string
  verified: boolean
  created_at: string
  updated_at: string
}

export type BreadcrumbItemType = BreadcrumbItem

export interface Session {
  id: string
  user_agent: string
  ip_address: string
  created_at: string
}
