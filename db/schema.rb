# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_02_050749) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "academic_periods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.date "start_date", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_academic_periods_on_organization_id"
  end

  create_table "ai_conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "exercise_set_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["exercise_set_id"], name: "index_ai_conversations_on_exercise_set_id"
    t.index ["user_id"], name: "index_ai_conversations_on_user_id"
  end

  create_table "ai_messages", force: :cascade do |t|
    t.bigint "ai_conversation_id", null: false
    t.text "content", default: "", null: false
    t.datetime "created_at", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.string "role", null: false
    t.string "status", default: "complete", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_conversation_id"], name: "index_ai_messages_on_ai_conversation_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enrollment_id", null: false
    t.text "notes"
    t.string "status", default: "absent", null: false
    t.bigint "tutoring_session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_attendances_on_enrollment_id"
    t.index ["tutoring_session_id", "enrollment_id"], name: "index_attendances_on_tutoring_session_id_and_enrollment_id", unique: true
    t.index ["tutoring_session_id"], name: "index_attendances_on_tutoring_session_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "academic_period_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_period_id"], name: "index_courses_on_academic_period_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "commitment_accepted_at"
    t.datetime "created_at", null: false
    t.bigint "section_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["section_id", "user_id"], name: "index_enrollments_on_section_id_and_user_id", unique: true
    t.index ["section_id"], name: "index_enrollments_on_section_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "exercise_sets", force: :cascade do |t|
    t.text "content", default: "", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.boolean "published", default: false, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "week_number", null: false
    t.index ["course_id", "week_number"], name: "index_exercise_sets_on_course_id_and_week_number"
    t.index ["course_id"], name: "index_exercise_sets_on_course_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "sections", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "max_students", default: 12, null: false
    t.string "name", null: false
    t.jsonb "schedule", default: {}, null: false
    t.bigint "tutor_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_sections_on_course_id"
    t.index ["tutor_id"], name: "index_sections_on_tutor_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tutoring_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.bigint "section_id", null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_tutoring_sessions_on_section_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "academic_periods", "organizations"
  add_foreign_key "ai_conversations", "exercise_sets"
  add_foreign_key "ai_conversations", "users"
  add_foreign_key "ai_messages", "ai_conversations"
  add_foreign_key "attendances", "enrollments"
  add_foreign_key "attendances", "tutoring_sessions"
  add_foreign_key "courses", "academic_periods"
  add_foreign_key "enrollments", "sections"
  add_foreign_key "enrollments", "users"
  add_foreign_key "exercise_sets", "courses"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "sections", "courses"
  add_foreign_key "sections", "users", column: "tutor_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "tutoring_sessions", "sections"
end
