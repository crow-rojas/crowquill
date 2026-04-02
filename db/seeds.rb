# frozen_string_literal: true

puts "Cleaning database..."
AiMessage.delete_all
AiConversation.delete_all
Attendance.delete_all
TutoringSession.delete_all
Enrollment.delete_all
ExerciseSet.delete_all
Section.delete_all
Course.delete_all
AcademicPeriod.delete_all
Membership.delete_all
Session.delete_all
Organization.delete_all
User.delete_all

puts "Seeding Crowquill..."

# === Organization ===
org = Organization.find_or_create_by!(slug: "pimu-uc") do |o|
  o.name = "PIMU UC"
  o.settings = {
    "max_messages_per_hour" => 30,
    "max_tokens_per_day" => 100_000
  }
end

# === Users ===
admin = User.find_or_create_by!(email: "admin@crowquill.dev") do |u|
  u.name = "Carolina Muñoz"
  u.password = "Password123456"
  u.verified = true
end

tutor1 = User.find_or_create_by!(email: "tutor1@crowquill.dev") do |u|
  u.name = "Sebastián Vega"
  u.password = "Password123456"
  u.verified = true
end

tutor2 = User.find_or_create_by!(email: "tutor2@crowquill.dev") do |u|
  u.name = "Francisca Rojas"
  u.password = "Password123456"
  u.verified = true
end

student_names = [
  "Martín González", "Valentina Silva", "Joaquín Pérez", "Isidora López",
  "Tomás Fernández", "Catalina Díaz", "Matías Soto", "Antonia Martínez",
  "Benjamín Araya", "Sofía Castillo", "Lucas Morales", "Emilia Vargas"
]

students = student_names.each_with_index.map do |name, i|
  User.find_or_create_by!(email: "alumno#{i + 1}@crowquill.dev") do |u|
    u.name = name
    u.password = "Password123456"
    u.verified = true
  end
end

# === Memberships ===
Membership.find_or_create_by!(user: admin, organization: org) { |m| m.role = "admin" }
Membership.find_or_create_by!(user: tutor1, organization: org) { |m| m.role = "tutor" }
Membership.find_or_create_by!(user: tutor2, organization: org) { |m| m.role = "tutor" }
students.each do |student|
  Membership.find_or_create_by!(user: student, organization: org) { |m| m.role = "tutorado" }
end

# === Academic Periods ===
period = AcademicPeriod.find_or_create_by!(organization: org, name: "1er Semestre 2026") do |p|
  p.start_date = Date.new(2026, 3, 9)
  p.end_date = Date.new(2026, 7, 17)
  p.status = "active"
end

AcademicPeriod.find_or_create_by!(organization: org, name: "2do Semestre 2025") do |p|
  p.start_date = Date.new(2025, 8, 4)
  p.end_date = Date.new(2025, 12, 12)
  p.status = "archived"
end

# === Courses ===
precalculo = Course.find_or_create_by!(academic_period: period, name: "Precálculo") do |c|
  c.description = "Repaso de funciones, trigonometría y álgebra para preparar Cálculo I."
end

calculo = Course.find_or_create_by!(academic_period: period, name: "Cálculo I") do |c|
  c.description = "Límites, derivadas e introducción a integrales."
end

# === Sections ===
sec_pre_1 = Section.find_or_create_by!(course: precalculo, name: "Precálculo - Sección A") do |s|
  s.tutor = tutor1
  s.max_students = 12
  s.schedule = {"day" => "monday", "start_time" => "14:00", "end_time" => "15:30", "room" => "S301"}
end

sec_pre_2 = Section.find_or_create_by!(course: precalculo, name: "Precálculo - Sección B") do |s|
  s.tutor = tutor2
  s.max_students = 12
  s.schedule = {"day" => "wednesday", "start_time" => "10:00", "end_time" => "11:30", "room" => "S205"}
end

sec_cal_1 = Section.find_or_create_by!(course: calculo, name: "Cálculo I - Sección A") do |s|
  s.tutor = tutor1
  s.max_students = 12
  s.schedule = {"day" => "thursday", "start_time" => "16:00", "end_time" => "17:30", "room" => "S301"}
end

sec_cal_2 = Section.find_or_create_by!(course: calculo, name: "Cálculo I - Sección B") do |s|
  s.tutor = tutor2
  s.max_students = 12
  s.schedule = {"day" => "friday", "start_time" => "09:00", "end_time" => "10:30", "room" => "S102"}
end

# === Enrollments ===
sections_students = {
  sec_pre_1 => students[0..5],
  sec_pre_2 => students[6..11],
  sec_cal_1 => students[0..3],
  sec_cal_2 => students[8..11]
}

sections_students.each do |section, section_students|
  section_students.each do |student|
    Enrollment.find_or_create_by!(section: section, user: student) do |e|
      e.status = "active"
      e.commitment_accepted_at = Time.current - rand(1..30).days
    end
  end
end

# One withdrawn student
if (withdrawn = Enrollment.find_by(section: sec_pre_1, user: students[5]))
  withdrawn.update!(status: "withdrawn")
end

# === Tutoring Sessions & Attendance ===
all_sections = [sec_pre_1, sec_pre_2, sec_cal_1, sec_cal_2]
session_dates = (1..6).map { |week| Date.new(2026, 3, 9) + (week * 7).days }

all_sections.each do |section|
  enrollments = section.enrollments.active

  session_dates.each_with_index do |date, week_idx|
    # Adjust date to match section schedule day
    day_offset = %w[monday tuesday wednesday thursday friday].index(section.schedule["day"]) || 0
    session_date = date.beginning_of_week + day_offset.days

    next if session_date > Date.current

    ts = TutoringSession.find_or_create_by!(section: section, date: session_date) do |s|
      s.status = "completed"
    end

    enrollments.each do |enrollment|
      Attendance.find_or_create_by!(tutoring_session: ts, enrollment: enrollment) do |a|
        # ~80% present, ~10% absent, ~10% justified
        roll = rand(100)
        a.status = if roll < 80
          "present"
        elsif roll < 90
          "absent"
        else
          "justified"
        end
        a.notes = "Justificación médica" if a.status == "justified"
      end
    end
  end

  # One upcoming session per section
  next_date = Date.current + 3.days
  day_offset = %w[monday tuesday wednesday thursday friday].index(section.schedule["day"]) || 0
  upcoming_date = next_date.beginning_of_week(:monday) + day_offset.days + 1.week

  TutoringSession.find_or_create_by!(section: section, date: upcoming_date) do |s|
    s.status = "scheduled"
  end
end

# === Exercise Sets ===
precalculo_exercises = [
  {
    title: "Funciones y dominio",
    week: 1,
    content: <<~LATEX
      ## Ejercicio 1: Dominio de funciones

      Determine el dominio de las siguientes funciones:

      1. $f(x) = \\frac{1}{x^2 - 4}$

      2. $g(x) = \\sqrt{3x - 6}$

      3. $h(x) = \\ln(x^2 - 1)$

      ## Ejercicio 2: Composición

      Dadas $f(x) = 2x + 1$ y $g(x) = x^2 - 3$, calcule:

      1. $(f \\circ g)(x)$
      2. $(g \\circ f)(2)$
    LATEX
  },
  {
    title: "Trigonometría básica",
    week: 2,
    content: <<~LATEX
      ## Identidades trigonométricas

      Demuestre las siguientes identidades:

      1. $\\sin^2(\\theta) + \\cos^2(\\theta) = 1$

      2. $\\tan(\\alpha + \\beta) = \\frac{\\tan\\alpha + \\tan\\beta}{1 - \\tan\\alpha\\tan\\beta}$

      ## Ejercicio

      Resuelva para $x \\in [0, 2\\pi]$:

      $$2\\sin^2(x) - \\sin(x) - 1 = 0$$
    LATEX
  },
  {
    title: "Inecuaciones y valor absoluto",
    week: 3,
    content: <<~LATEX
      ## Valor absoluto

      Resuelva las siguientes inecuaciones:

      1. $|2x - 5| < 3$

      2. $|x + 1| \\geq 4$

      ## Inecuaciones cuadráticas

      Determine el conjunto solución de:

      $$x^2 - 5x + 6 > 0$$

      **Hint:** Factorice el polinomio primero.
    LATEX
  },
  {
    title: "Funciones exponenciales y logarítmicas",
    week: 4,
    content: <<~LATEX
      ## Propiedades de logaritmos

      Simplifique usando propiedades de logaritmos:

      1. $\\log_2(8) + \\log_2(4)$

      2. $\\ln(e^3 \\cdot e^2)$

      3. $\\log\\left(\\frac{1000}{10}\\right)$

      ## Ecuaciones exponenciales

      Resuelva:

      $$3^{2x-1} = 27$$

      $$e^{x^2 - 1} = 1$$
    LATEX
  }
]

calculo_exercises = [
  {
    title: "Introducción a límites",
    week: 1,
    content: <<~LATEX
      ## Límites algebraicos

      Calcule los siguientes límites:

      1. $\\lim_{x \\to 2} \\frac{x^2 - 4}{x - 2}$

      2. $\\lim_{x \\to 0} \\frac{\\sin(x)}{x}$

      3. $\\lim_{x \\to \\infty} \\frac{3x^2 + 1}{x^2 - 5}$

      ## Límites laterales

      Determine si existe $\\lim_{x \\to 0} f(x)$ donde:

      $$f(x) = \\begin{cases} x + 1 & \\text{si } x < 0 \\\\ 2x + 1 & \\text{si } x \\geq 0 \\end{cases}$$
    LATEX
  },
  {
    title: "Derivadas: reglas básicas",
    week: 2,
    content: <<~LATEX
      ## Reglas de derivación

      Calcule $f'(x)$ para cada función:

      1. $f(x) = 3x^4 - 2x^2 + 7x - 1$

      2. $f(x) = \\sqrt{x} + \\frac{1}{x}$

      3. $f(x) = (2x + 1)(x^2 - 3)$ *(use regla del producto)*

      4. $f(x) = \\frac{x^2 + 1}{x - 1}$ *(use regla del cociente)*

      ## Aplicación

      La posición de una partícula está dada por $s(t) = t^3 - 6t^2 + 9t$.

      Determine la velocidad $v(t) = s'(t)$ y los instantes donde la partícula se detiene.
    LATEX
  },
  {
    title: "Regla de la cadena",
    week: 3,
    content: <<~LATEX
      ## Regla de la cadena

      Derive las siguientes funciones compuestas:

      1. $f(x) = (3x^2 + 1)^5$

      2. $g(x) = \\sin(2x^2)$

      3. $h(x) = e^{-x^2}$

      4. $p(x) = \\ln(\\cos(x))$

      ## Derivación implícita

      Dada la ecuación $x^2 + y^2 = 25$, encuentre $\\frac{dy}{dx}$.
    LATEX
  }
]

precalculo_exercises.each do |ex|
  ExerciseSet.find_or_create_by!(course: precalculo, week_number: ex[:week]) do |e|
    e.title = ex[:title]
    e.content = ex[:content]
    e.published = true
    e.metadata = {"difficulty" => "medium", "topic" => ex[:title].downcase}
  end
end

calculo_exercises.each do |ex|
  ExerciseSet.find_or_create_by!(course: calculo, week_number: ex[:week]) do |e|
    e.title = ex[:title]
    e.content = ex[:content]
    e.published = ex[:week] <= 2  # Week 3 is draft
    e.metadata = {"difficulty" => "medium", "topic" => ex[:title].downcase}
  end
end

# === AI Conversations ===
ai_student = students[0]

conv1 = AiConversation.find_or_create_by!(user: ai_student, title: "Ayuda con dominio de funciones") do |c|
  c.exercise_set = ExerciseSet.find_by(course: precalculo, week_number: 1)
end

unless conv1.ai_messages.exists?
  conv1.ai_messages.create!(
    role: "user",
    content: "No entiendo cómo encontrar el dominio de $f(x) = \\frac{1}{x^2 - 4}$",
    status: "complete"
  )
  conv1.ai_messages.create!(
    role: "assistant",
    content: "¡Buena pregunta! Para encontrar el dominio, necesitas identificar los valores de $x$ que **no** están permitidos.\n\nPiensa: ¿qué pasa con una fracción cuando el denominador es cero? 🤔\n\n¿Puedes decirme para qué valores de $x$ se cumple que $x^2 - 4 = 0$?",
    status: "complete",
    input_tokens: 150,
    output_tokens: 80
  )
  conv1.ai_messages.create!(
    role: "user",
    content: "Cuando $x = 2$ o $x = -2$ porque $x^2 = 4$",
    status: "complete"
  )
  conv1.ai_messages.create!(
    role: "assistant",
    content: "¡Exacto! Has factorizado correctamente: $x^2 - 4 = (x-2)(x+2) = 0$ cuando $x = 2$ o $x = -2$.\n\nEntonces el dominio es todos los reales **excepto** esos dos valores. En notación matemática:\n\n$$\\text{Dom}(f) = \\mathbb{R} \\setminus \\{-2, 2\\}$$\n\no equivalentemente: $(-\\infty, -2) \\cup (-2, 2) \\cup (2, +\\infty)$.\n\n¿Te animas a intentar el siguiente ejercicio con $g(x) = \\sqrt{3x - 6}$? La condición para raíces cuadradas es diferente...",
    status: "complete",
    input_tokens: 200,
    output_tokens: 120
  )
end

conv2 = AiConversation.find_or_create_by!(user: ai_student, title: "Duda sobre límites") do |c|
  c.exercise_set = ExerciseSet.find_by(course: calculo, week_number: 1)
end

unless conv2.ai_messages.exists?
  conv2.ai_messages.create!(
    role: "user",
    content: "¿Cómo calculo $\\lim_{x \\to 2} \\frac{x^2 - 4}{x - 2}$? Si reemplazo da $\\frac{0}{0}$",
    status: "complete"
  )
  conv2.ai_messages.create!(
    role: "assistant",
    content: "Muy buena observación — obtener $\\frac{0}{0}$ es una **forma indeterminada**, lo que significa que necesitas manipular la expresión antes de evaluar.\n\n¿Reconoces alguna factorización especial en el numerador $x^2 - 4$? \n\n*Pista: es una diferencia de cuadrados...*",
    status: "complete",
    input_tokens: 180,
    output_tokens: 75
  )
end

# Second student also has a conversation
conv3 = AiConversation.find_or_create_by!(user: students[1], title: "Trigonometría - identidades")

unless conv3.ai_messages.exists?
  conv3.ai_messages.create!(
    role: "user",
    content: "Tengo que resolver $2\\sin^2(x) - \\sin(x) - 1 = 0$ y no sé por dónde empezar",
    status: "complete"
  )
  conv3.ai_messages.create!(
    role: "assistant",
    content: "¡Intentemos algo! Si haces una sustitución $u = \\sin(x)$, ¿cómo se ve la ecuación?\n\nEscríbela reemplazando $\\sin(x)$ por $u$ y dime qué tipo de ecuación obtienes.",
    status: "complete",
    input_tokens: 160,
    output_tokens: 65
  )
end

# === Summary ===
puts ""
puts "=== Seed complete ==="
puts "  Organization: #{Organization.count}"
puts "  Users: #{User.count} (1 admin, 2 tutors, #{students.size} students)"
puts "  Memberships: #{Membership.count}"
puts "  Academic Periods: #{AcademicPeriod.count}"
puts "  Courses: #{Course.count}"
puts "  Sections: #{Section.count}"
puts "  Enrollments: #{Enrollment.count} (#{Enrollment.where(status: 'active').count} active, #{Enrollment.where(status: 'withdrawn').count} withdrawn)"
puts "  Tutoring Sessions: #{TutoringSession.count} (#{TutoringSession.where(status: 'completed').count} completed, #{TutoringSession.where(status: 'scheduled').count} scheduled)"
puts "  Attendance Records: #{Attendance.count}"
puts "  Exercise Sets: #{ExerciseSet.count} (#{ExerciseSet.where(published: true).count} published, #{ExerciseSet.where(published: false).count} draft)"
puts "  AI Conversations: #{AiConversation.count}"
puts "  AI Messages: #{AiMessage.count}"
puts ""
puts "=== Login credentials (all passwords: Password123456) ==="
puts "  Admin:     admin@crowquill.dev"
puts "  Tutor 1:   tutor1@crowquill.dev"
puts "  Tutor 2:   tutor2@crowquill.dev"
puts "  Alumno 1:  alumno1@crowquill.dev  (has AI conversations)"
puts "  Alumno 2:  alumno2@crowquill.dev  (has AI conversation)"
puts "==========================================================="
