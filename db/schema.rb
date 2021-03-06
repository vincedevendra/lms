# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151214020439) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "point_value"
    t.date     "due_date"
    t.integer  "course_id"
    t.boolean  "submission_required"
  end

  create_table "courses", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.string   "code",          limit: 255
    t.string   "location",      limit: 255
    t.string   "meeting_days",  limit: 255
    t.string   "start_time",    limit: 255
    t.string   "end_time",      limit: 255
    t.text     "notes"
    t.integer  "instructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grades", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "assignment_id"
    t.float    "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer  "course_id"
    t.string   "email"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.string   "submission"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
    t.string   "box_view_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.string   "password_digest", limit: 255
    t.string   "student_id",      limit: 255
    t.boolean  "instructor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
  end

end
