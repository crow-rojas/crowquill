---
title: "fix: UX polish — navigation, breadcrumbs, hardcoded routes, and frontend tests"
type: fix
status: active
date: 2026-04-02
origin: docs/plans/2026-04-02-001-feat-tutoring-mvp-plan.md
---

# fix: UX polish — navigation, breadcrumbs, hardcoded routes, and frontend tests

## Overview

Post-MVP polish pass to fix broken navigation, dead-end breadcrumbs, hardcoded routes, and missing frontend test coverage. The MVP shipped functional features but the UI has navigation issues that hurt usability across all roles.

## Problem Frame

The MVP was built fast with subagents that worked in isolation. This produced consistent backend quality but fragmented frontend patterns: breadcrumbs with `"#"` placeholder hrefs, hardcoded URL strings instead of route helpers, missing i18n for settings, and an AppHeader with English-only hardcoded strings. No frontend component tests exist beyond FormInput, LatexRenderer, ExerciseEditor, and usePermissions.

## Requirements Trace

- R1. **All breadcrumbs functional** — every breadcrumb links to a real, reachable page
- R2. **Route helpers everywhere** — no hardcoded URL strings in Vue files
- R3. **i18n complete** — no hardcoded English strings, settings translations exist
- R4. **Frontend test coverage** — NavMain, AppSidebar, dashboard components, and key pages have tests
- R5. **Breadcrumb component improvement** — current page renders without link, not `"#"`

## Scope Boundaries

- No new features (QR, notifications, etc.)
- No backend changes except where controllers need to pass additional props for breadcrumbs
- No redesign — keep existing layouts and components
- No mobile-specific redesign — just ensure existing responsive behavior works

## Key Technical Decisions

- **Fix breadcrumbs by making last item non-clickable**: The Breadcrumbs component should render the last item as plain text (current page), not as a link. This is the standard UX pattern and eliminates the `"#"` problem at the source.
- **Replace all hardcoded routes systematically**: Use the generated route helpers from `@/routes`. Grep for patterns like `href="/`, `href=\`/`, and template literal routes.
- **Settings i18n already exists in nav.json**: The settings translations are nested inside `nav.json` under `settings.*`. Verify they're being used correctly — the issue may be key path mismatches, not missing files.

## Implementation Units

- [ ] **Unit 1: Fix Breadcrumbs component — last item as plain text**

  **Goal:** Make the last breadcrumb item render as non-clickable text (current page indicator).

  **Requirements:** R1, R5

  **Files:**
  - Modify: `app/frontend/components/Breadcrumbs.vue`
  - Test: `spec/frontend/components/Breadcrumbs.spec.ts`

  **Approach:**
  - Check if the item is the last in the array; if so, render as `BreadcrumbPage` (plain text) instead of `BreadcrumbLink`
  - This eliminates the need for `"#"` hrefs on create/edit/show pages

  **Patterns to follow:**
  - shadcn-vue Breadcrumb component docs (BreadcrumbPage for current item)

  **Test scenarios:**
  - Last breadcrumb renders as plain text, not a link
  - Middle breadcrumbs render as links with correct hrefs
  - Single breadcrumb renders as plain text

  **Verification:**
  - No `"#"` hrefs in any breadcrumb across the app

- [ ] **Unit 2: Replace all hardcoded "/dashboard" with dashboardPath()**

  **Goal:** Use route helpers for dashboard links in all 16+ pages.

  **Requirements:** R2

  **Files:**
  - Modify: All pages in `app/frontend/pages/` that use `href: "/dashboard"`
  - Modify: `app/frontend/components/AppHeader.vue`

  **Approach:**
  - Grep for `"/dashboard"` in all Vue files
  - Replace with `dashboardPath()` import from `@/routes`
  - Also fix AppHeader hardcoded "Dashboard" string → `t("nav.dashboard")`

  **Test scenarios:**
  - Grep for `"/dashboard"` returns zero matches in Vue files after fix

  **Verification:**
  - All dashboard references use route helper

- [ ] **Unit 3: Replace all hardcoded route strings with route helpers**

  **Goal:** Replace template literal routes (`/sections/${id}/enrollments`) with generated helpers.

  **Requirements:** R2

  **Files:**
  - Modify: `app/frontend/pages/Sections/Show.vue`
  - Modify: `app/frontend/pages/Enrollments/Index.vue`
  - Modify: `app/frontend/pages/TutoringSessions/Index.vue`
  - Modify: `app/frontend/pages/TutoringSessions/Show.vue`
  - Modify: `app/frontend/pages/TutoringSessions/New.vue`
  - Modify: `app/frontend/components/AttendanceGrid.vue`
  - Modify: `app/frontend/components/CommitmentDialog.vue`

  **Approach:**
  - Replace hardcoded strings with: `sectionEnrollmentsPath(id)`, `sectionTutoringSessionsPath(id)`, `newSectionTutoringSessionPath(id)`, `tutoringSessionPath(id)`, `enrollmentPath(id)`, `tutoringSessionAttendancesPath(id)`
  - Check `app/frontend/routes/index.d.ts` for all available helpers

  **Test scenarios:**
  - Grep for template literal routes (`` `/sections/ ``, `` `/tutoring_sessions/ ``, `` `/enrollments/ ``) returns zero matches

  **Verification:**
  - All Vue files use route helpers from `@/routes`, no hardcoded paths

- [ ] **Unit 4: Fix breadcrumb "#" hrefs in all pages**

  **Goal:** After Unit 1 (last item is plain text), fix remaining middle breadcrumbs that use `"#"`.

  **Requirements:** R1

  **Files:**
  - Modify: Pages in `AcademicPeriods/`, `Courses/`, `Sections/`, `ExerciseSets/`, `TutoringSessions/`, `AiConversations/`, `Enrollments/`

  **Approach:**
  - Most `"#"` hrefs are on the LAST breadcrumb (current page) — Unit 1 fixes these by not rendering a link
  - For any remaining middle breadcrumbs with `"#"`, replace with proper route helpers
  - Ensure breadcrumb chains are complete: Dashboard → Period → Course → Section (with real links at each level)
  - Pages need the parent resource passed as props from the controller for complete breadcrumb chains (e.g., Sections/Edit needs the course)

  **Verification:**
  - Grep for `href: "#"` returns zero matches in Vue files

- [ ] **Unit 5: Fix AppHeader i18n and route helpers**

  **Goal:** Replace hardcoded English strings and routes in AppHeader.

  **Requirements:** R3

  **Files:**
  - Modify: `app/frontend/components/AppHeader.vue`

  **Approach:**
  - Import `useI18n` and `dashboardPath`
  - Replace `"Dashboard"` with `t("nav.dashboard")`
  - Replace `"/dashboard"` with `dashboardPath()`

  **Verification:**
  - No hardcoded English strings in AppHeader

- [ ] **Unit 6: Add frontend tests for NavMain and AppSidebar**

  **Goal:** Test navigation rendering and active state logic per role.

  **Requirements:** R4

  **Files:**
  - Create: `spec/frontend/components/NavMain.spec.ts`
  - Create: `spec/frontend/components/AppSidebar.spec.ts`

  **Approach:**
  - NavMain: test `isActive()` function with various page.url values (exact match, nested, query params)
  - AppSidebar: test that different roles produce different nav items

  **Test scenarios:**
  - NavMain: `/academic_periods` active when on `/academic_periods/1/courses`
  - NavMain: `/dashboard` NOT active when on `/academic_periods`
  - NavMain: active state works with query params (`?page=2`)
  - AppSidebar: admin sees Academic Periods nav item
  - AppSidebar: tutorado sees My Sections nav item
  - AppSidebar: all roles see AI Chat

  **Verification:**
  - All navigation tests pass

- [ ] **Unit 7: Add frontend tests for dashboard components**

  **Goal:** Test that each dashboard renders correct content for its role.

  **Requirements:** R4

  **Files:**
  - Create: `spec/frontend/components/AdminDashboard.spec.ts`
  - Create: `spec/frontend/components/TutorDashboard.spec.ts`
  - Create: `spec/frontend/components/TutoradoDashboard.spec.ts`

  **Test scenarios:**
  - AdminDashboard renders stat cards with counts
  - TutorDashboard renders section list
  - TutoradoDashboard renders enrolled sections and exercise links
  - Each component renders correctly with empty data

  **Verification:**
  - Dashboard component tests pass

## Risks & Dependencies

- **Breadcrumb completeness depends on controller props**: Some pages may not receive the full parent chain (e.g., Section edit doesn't get the course for breadcrumbs). Controllers may need minor prop additions.
- **Route helper availability**: Verify all needed route helpers exist in `app/frontend/routes/index.d.ts` before replacing hardcoded routes.

## Sources & References

- Existing route helpers: `app/frontend/routes/index.d.ts`
- shadcn-vue Breadcrumb: BreadcrumbPage component for current item
- Existing test patterns: `spec/frontend/components/FormInput.spec.ts`, `spec/frontend/unit/usePermissions.spec.ts`
