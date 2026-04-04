export interface DashboardSession {
  id: number
  date: string
  status: "scheduled" | "completed" | "cancelled"
  section: { id: number; name: string }
  course: { id: number; name: string }
  attendance_count?: number
}

export interface DashboardSection {
  id: number
  name: string
  schedule: Record<string, unknown>
  max_students?: number
  course: { id: number; name: string }
  enrollments_count?: number
}

export interface DashboardExercise {
  id: number
  title: string
  week_number: number
  course_id: number
}

export interface DashboardPeriod {
  id: number
  year: number
  semester: 1 | 2
  name: string | null
  start_date: string
  end_date: string
  status: "draft" | "active" | "archived"
}

export interface AdminDashboardProps {
  role: "admin"
  active_period: DashboardPeriod | null
  total_students: number
  total_tutors: number
  active_sections: number
  recent_sessions: DashboardSession[]
}

export interface TutorDashboardProps {
  role: "tutor"
  my_sections: DashboardSection[]
  upcoming_sessions: DashboardSession[]
  next_session: DashboardSession | null
}

export interface TutoradoDashboardProps {
  role: "tutorado"
  my_sections: DashboardSection[]
  upcoming_sessions: DashboardSession[]
  recent_exercises: DashboardExercise[]
  next_session: DashboardSession | null
}

export type DashboardProps =
  | AdminDashboardProps
  | TutorDashboardProps
  | TutoradoDashboardProps
  | { role?: undefined }
