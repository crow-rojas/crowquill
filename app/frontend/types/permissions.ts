export interface Permissions {
  manage_sections: boolean
  manage_exercises: boolean
  manage_academic_periods: boolean
  manage_courses: boolean
  take_attendance: boolean
  view_attendance_statistics: boolean
  manage_enrollments: boolean
  create_ai_conversations: boolean
}

export type Role = "admin" | "tutor" | "tutorado"

export interface Membership {
  id: number
  role: Role
}
