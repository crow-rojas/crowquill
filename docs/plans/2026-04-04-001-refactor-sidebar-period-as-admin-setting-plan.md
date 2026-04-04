---
title: "refactor: Simplify sidebar navigation and treat academic period as admin setting"
type: refactor
status: active
date: 2026-04-04
---

# refactor: Simplify sidebar navigation and treat academic period as admin setting

## Overview

Remove the "Academic Management" / "Current Period" navigation from the sidebar for all roles. Replace with a direct "Courses" link pointing to the active period's courses. The academic period switcher in the header becomes admin-only (dropdown with manage link); non-admins see a read-only YYYY-S badge for context.

## Problem Frame

The sidebar currently exposes academic period navigation ("Current Period", "Academic Periods") which is confusing — period management is an admin concern, not something tutors/students should navigate. Users want to get to their courses directly, not go through a period first. The period should be ambient context (visible in the header) that admins can change, not a navigation destination for all roles.

## Requirements Trace

- R1. Sidebar shows a direct "Courses" link for all roles (links to active period's courses)
- R2. Admin sidebar no longer has "Academic Management" group or "Academic Periods" link
- R3. Header period badge is read-only for non-admins (no dropdown, not clickable)
- R4. Header period dropdown remains for admins with period switching + "Manage periods" link
- R5. Existing Academic Periods CRUD pages remain unchanged (accessed via header dropdown for admins)
- R6. When no active period exists, "Courses" link gracefully handles the absence

## Scope Boundaries

- Academic Periods CRUD pages (Index, Show, New, Edit) are NOT being changed
- Routes and controllers are NOT being changed
- The period dropdown behavior for admins stays mostly the same (navigate to period show page)
- No new routes or controllers needed

## Context & Research

### Relevant Code and Patterns

- `app/frontend/components/AppSidebar.vue` — builds `mainNavItems` array based on role
- `app/frontend/components/AppSidebarHeader.vue` — header with period dropdown
- `app/frontend/components/NavMain.vue` — renders sidebar nav items
- `app/frontend/composables/usePermissions.ts` — provides `can`, `isAdmin`, `isTutor`, `isTutorado`
- `app/frontend/routes/index.js` — `academicPeriodCoursesPath(academicPeriodId)` exists
- Routes: courses are at `/academic_periods/:id/courses` (nested under academic periods)
- i18n: `nav.json` has `current_period`, `academic_periods`, `academic_management`, `teaching`, `learning`

### Key Observations

- `academicPeriodCoursesPath(id)` is the route helper for the courses list page
- The active period comes from `auth.academic_period_context.active`
- `usePermissions()` already exposes `isAdmin` — can be used to gate header dropdown
- The sidebar currently has distinct groups for admin vs tutor/tutorado — this simplification unifies them

## Key Technical Decisions

- **Courses link target**: Use `academicPeriodCoursesPath(activePeriod.id)` when active period exists, fall back to `academicPeriodsPath()` when there's no active period (so users land on the periods list to find what they need)
- **Header admin check**: Use `can.manage_academic_periods` (already exists) to gate the dropdown vs read-only badge
- **Sidebar simplification**: Remove all role-specific academic groupings (Academic Management, Teaching, Learning). All roles get the same flat "Courses" item.
- **Keep "Manage periods" in dropdown**: Add a "Manage periods" link in the admin dropdown pointing to `academicPeriodsPath()` so admins can still CRUD periods

## Implementation Units

- [ ] **Unit 1: Simplify sidebar — replace period navigation with Courses link**

  **Goal:** All roles see a flat "Courses" link in the sidebar instead of role-specific academic period groups.

  **Requirements:** R1, R2, R6

  **Dependencies:** None

  **Files:**
  - Modify: `app/frontend/components/AppSidebar.vue`
  - Modify: `app/frontend/i18n/locales/en/nav.json`
  - Modify: `app/frontend/i18n/locales/es/nav.json`
  - Test: `spec/frontend/components/AppSidebar.spec.ts`

  **Approach:**
  - Remove the admin "Academic Management" group block and the tutor/tutorado "Teaching"/"Learning" group blocks from `mainNavItems`
  - Add a single "Courses" nav item (BookOpen icon) for all roles between Dashboard and AI Chat
  - Href: `academicPeriodCoursesPath(activePeriod.id)` when active period exists, `academicPeriodsPath()` otherwise
  - Import `academicPeriodCoursesPath` from `@/routes` and `BookOpen` from lucide
  - Add i18n key `nav.courses` in both locales ("Courses" / "Cursos")

  **Patterns to follow:**
  - The existing Dashboard item pattern in `AppSidebar.vue` (flat item, no children)

  **Test scenarios:**
  - Admin with active period → "Courses" item links to `/academic_periods/:id/courses`
  - Tutorado with no active period → "Courses" item falls back to `/academic_periods`
  - No "Academic Management", "Teaching", or "Learning" groups appear for any role
  - AI Chat still present for all roles

  **Verification:**
  - Sidebar renders a single "Courses" link for all roles
  - No academic period navigation groups in sidebar

- [ ] **Unit 2: Make header period badge read-only for non-admins**

  **Goal:** Non-admins see a static YYYY-S badge in the header; admins keep the full dropdown with period switching and a "Manage periods" link.

  **Requirements:** R3, R4

  **Dependencies:** None (can be done in parallel with Unit 1)

  **Files:**
  - Modify: `app/frontend/components/AppSidebarHeader.vue`
  - Modify: `app/frontend/i18n/locales/en/nav.json`
  - Modify: `app/frontend/i18n/locales/es/nav.json`
  - Test: `spec/frontend/components/AppSidebarHeader.spec.ts`

  **Approach:**
  - Import `usePermissions` composable, extract `can`
  - Split the period display into two branches:
    - `can.manage_academic_periods` → current DropdownMenu with trigger button (keep existing admin behavior), add a "Manage periods" `DropdownMenuItem` linking to `academicPeriodsPath()` (between separator and "View all periods" — or replace "View all periods" with "Manage periods" since the label better fits the admin-setting framing)
    - Otherwise → static Button (no dropdown trigger) showing the `activePeriodLabel` badge, not clickable (use `disabled` or just a non-interactive element like a div styled as a badge)
  - For the non-admin badge: use a simple `div` or `Badge` component styled like the current button but without interaction affordances (no hover effect, no cursor pointer)
  - Rename i18n key `nav.view_all_periods` to `nav.manage_periods` / "Manage periods" / "Gestionar periodos" (or add a new key and keep the old one)

  **Patterns to follow:**
  - Existing `usePermissions()` usage pattern in other components

  **Test scenarios:**
  - Admin sees dropdown with period list and "Manage periods" link
  - Non-admin sees static period badge, no dropdown menu rendered
  - When no academic periods exist, neither admin nor non-admin sees a badge
  - Admin can still navigate to individual periods via dropdown items

  **Verification:**
  - Non-admin header shows "2026-1" as plain text/badge
  - Admin header shows clickable dropdown with period switching
  - "Manage periods" link appears in admin dropdown

## System-Wide Impact

- **Navigation flow change:** Users who previously navigated Sidebar → Current Period → Courses now go Sidebar → Courses directly. One fewer click.
- **Admin period access:** Admins access period management from the header dropdown instead of the sidebar. The CRUD pages themselves don't change.
- **Active state detection in NavMain:** The "Courses" href will be `/academic_periods/:id/courses`. NavMain's `isActive` uses `startsWith` matching, so it will correctly highlight when the user is on a course page nested under that path. Verify that it doesn't also highlight when on `/academic_periods/:id` (the period show page).

## Risks & Dependencies

- **No active period state:** When no period is active, the "Courses" link falls back to the academic periods list. This is acceptable but means non-admins will see the periods index page (which they have read access to via policy).
- **NavMain active state:** `startsWith("/academic_periods/X/courses")` may also match when on `/academic_periods/X` (period show). This is unlikely to cause issues since admins access the period show page from the header, not the sidebar, but worth verifying.

## Sources & References

- Related code: `app/frontend/components/AppSidebar.vue`, `app/frontend/components/AppSidebarHeader.vue`
- Related code: `app/frontend/composables/usePermissions.ts`
- Related code: `app/frontend/routes/index.js` — `academicPeriodCoursesPath`
