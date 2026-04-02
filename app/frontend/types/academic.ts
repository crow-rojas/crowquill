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
  can_view_sessions?: boolean
  created_at: string
  updated_at: string
}

export interface ExerciseSet {
  id: number
  course_id: number
  title: string
  week_number: number
  content: string
  metadata: Record<string, unknown>
  published: boolean
  course?: Course
  created_at: string
  updated_at: string
}

export interface TutoringSession {
  id: number
  section_id: number
  date: string
  status: "scheduled" | "completed" | "cancelled"
  section?: Section & {
    course?: Course
    tutor?: { id: number; name: string; email: string }
  }
  created_at: string
  updated_at: string
}

export interface Attendance {
  id: number
  tutoring_session_id: number
  enrollment_id: number
  status: "present" | "absent" | "justified"
  notes: string | null
  enrollment?: Enrollment
  created_at: string
  updated_at: string
}

export interface AiConversation {
  id: number
  user_id: number
  exercise_set_id: number | null
  title: string
  ai_messages?: AiMessage[]
  created_at: string
  updated_at: string
}

export interface AiMessage {
  id: number
  ai_conversation_id: number
  role: "user" | "assistant"
  content: string
  status: "streaming" | "complete" | "failed"
  input_tokens: number | null
  output_tokens: number | null
  created_at: string
  updated_at: string
}

export interface Enrollment {
  id: number
  section_id: number
  user_id: number
  status: "active" | "withdrawn"
  commitment_accepted_at: string | null
  user?: { id: number; name: string; email: string }
  section?: Section
  created_at: string
  updated_at: string
}
