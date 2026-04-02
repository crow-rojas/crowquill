export interface AcademicPeriod {
  id: number
  name: string
  start_date: string
  end_date: string
  status: "draft" | "active" | "archived"
  created_at: string
  updated_at: string
}

export interface Course {
  id: number
  name: string
  description: string | null
  academic_period_id: number
  academic_period?: AcademicPeriod
  created_at: string
  updated_at: string
}

export interface Section {
  id: number
  name: string
  schedule: Record<string, unknown>
  max_students: number
  course_id: number
  tutor_id: number
  tutor?: { id: number; name: string; email: string }
  course?: Course
  enrollments_count?: number
  created_at: string
  updated_at: string
}
