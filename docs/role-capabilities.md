# Role Capabilities Matrix

Last updated: 2026-04-02

This document summarizes what each role can do in Crowquill, based on current policy rules and controller behavior.

## Roles

- admin
- tutor
- tutorado

Role hierarchy: admin > tutor > tutorado.

## Capability Matrix

Legend:

- ✅ Allowed
- ⚠️ Allowed with constraints
- ❌ Not allowed

| Domain            | Action                           | admin | tutor | tutorado | Notes                                                                          |
| ----------------- | -------------------------------- | ----- | ----- | -------- | ------------------------------------------------------------------------------ |
| Academic Periods  | List / View                      | ✅    | ✅    | ✅       | Membership required                                                            |
| Academic Periods  | Create / Edit / Delete           | ✅    | ❌    | ❌       | Admin only                                                                     |
| Courses           | List / View                      | ✅    | ✅    | ✅       | Membership required                                                            |
| Courses           | Create / Edit / Delete           | ✅    | ❌    | ❌       | Admin only                                                                     |
| Sections          | List / View                      | ✅    | ⚠️    | ⚠️       | Tutor: own sections. Tutorado: enrolled or available sections                  |
| Sections          | Create / Edit / Delete           | ✅    | ❌    | ❌       | Admin only                                                                     |
| Enrollments       | List                             | ✅    | ⚠️    | ⚠️       | Tutor: own sections. Tutorado: only own enrollment in enrolled sections        |
| Enrollments       | Create                           | ✅    | ❌    | ✅       | Tutorado can create own enrollment                                             |
| Enrollments       | Update (withdraw)                | ✅    | ❌    | ⚠️       | Tutorado only for own enrollment                                               |
| Enrollments       | Delete                           | ✅    | ❌    | ❌       | Admin only                                                                     |
| Tutoring Sessions | List / View                      | ✅    | ⚠️    | ⚠️       | Tutor: own sections. Tutorado: enrolled only                                   |
| Tutoring Sessions | New / Edit forms                 | ✅    | ⚠️    | ❌       | Tutor only for own section                                                     |
| Tutoring Sessions | Create / Update                  | ✅    | ⚠️    | ❌       | Tutor only for own section                                                     |
| Tutoring Sessions | Delete                           | ✅    | ❌    | ❌       | Admin only                                                                     |
| Attendance        | Update attendance                | ✅    | ⚠️    | ❌       | Tutor only for own section                                                     |
| Attendance        | View statistics                  | ✅    | ❌    | ❌       | Admin only permission                                                          |
| Exercise Sets     | List                             | ✅    | ✅    | ✅       | Membership required                                                            |
| Exercise Sets     | View details                     | ✅    | ⚠️    | ⚠️       | Non-admin: published only                                                      |
| Exercise Sets     | Create / Edit / Delete           | ✅    | ❌    | ❌       | Admin only                                                                     |
| Exercise Sets     | Publish / Unpublish              | ✅    | ❌    | ❌       | Admin only                                                                     |
| AI Conversations  | List / View / Create             | ✅    | ✅    | ✅       | Scoped to current user; non-admin exercise set linking requires published sets |
| AI Messages       | Send message                     | ✅    | ✅    | ✅       | Only inside own conversation                                                   |
| Dashboard         | Role-specific dashboard          | ✅    | ✅    | ✅       | Rendered by membership role                                                    |
| Settings          | Profile / Email / Password       | ✅    | ✅    | ✅       | Authenticated users; membership not required                                   |
| Settings          | Sessions / Appearance / Language | ✅    | ✅    | ✅       | Authenticated users; membership not required                                   |
| Dev User Switch   | Switch user (development only)   | ⚠️    | ⚠️    | ⚠️       | Requires membership + flag + development env                                   |

## Important Constraints

### Tutoring session ownership

Tutors can create and update tutoring sessions only when the session belongs to a section they tutor. Admin bypasses this ownership constraint.

Tutors can only list and view sessions from sections they tutor. Tutorado users can list and view sessions only for sections where they have an active enrollment.

In session details, tutorado users only receive their own enrollment and attendance record.

### Section visibility

Tutors can only see sections assigned to them.

Tutorado users can see sections where they are already enrolled and sections that still have available capacity.

Tutorado users cannot access full sections where they are not enrolled.

### Enrollment list visibility

Admins can view full enrollment rosters.

Tutors can view enrollment rosters only for sections they own.

Tutorado users can open enrollment lists only for sections where they have an active enrollment, and they only receive their own enrollment row.

### Exercise set visibility

Non-admin users can only view published exercise sets.

When creating AI conversations, non-admin users can only link published exercise sets.

### AI data isolation

Even though all roles can use AI chat, conversations and messages are constrained to the current authenticated user.

### Settings availability

Settings controllers skip membership requirement, so authenticated users can access settings even if they do not have a membership yet.

### Dev switcher behavior

The fast user switcher is not role-restricted by policy. It is gated by:

- development environment
- DEV_USER_SWITCH_ENABLED
- current user having membership context
- target user belonging to current organization

## Navigation-level role behavior

Sidebar behavior is role-aware through shared permissions:

- admin sees Dashboard + Academic Management group + AI Chat
- tutor sees Dashboard + Teaching group (My Sections) + AI Chat
- tutorado sees Dashboard + Learning group (My Sections) + AI Chat
- all roles see AI Chat

## Source References

Primary authorization and behavior references:

- app/models/membership.rb
- app/policies/application_policy.rb
- app/policies/academic_period_policy.rb
- app/policies/course_policy.rb
- app/policies/section_policy.rb
- app/policies/enrollment_policy.rb
- app/policies/tutoring_session_policy.rb
- app/policies/attendance_policy.rb
- app/policies/exercise_set_policy.rb
- app/policies/ai_conversation_policy.rb
- app/controllers/inertia_controller.rb
- app/controllers/dashboard_controller.rb
- app/controllers/ai_conversations_controller.rb
- app/controllers/ai_messages_controller.rb
- app/controllers/settings/profiles_controller.rb
- app/controllers/settings/emails_controller.rb
- app/controllers/settings/passwords_controller.rb
- app/controllers/settings/sessions_controller.rb
- app/controllers/settings/appearance_controller.rb
- app/controllers/settings/language_controller.rb
- app/controllers/sessions_controller.rb
- app/frontend/components/AppSidebar.vue
