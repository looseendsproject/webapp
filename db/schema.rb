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

ActiveRecord::Schema[8.0].define(version: 2025_04_04_193324) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assessments", force: :cascade do |t|
    t.bigint "skill_id"
    t.bigint "finisher_id"
    t.integer "rating", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["finisher_id"], name: "index_assessments_on_finisher_id"
    t.index ["skill_id"], name: "index_assessments_on_skill_id"
  end

  create_table "assignment_updates", force: :cascade do |t|
    t.bigint "assignment_id"
    t.bigint "user_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_assignment_updates_on_assignment_id"
    t.index ["user_id"], name: "index_assignment_updates_on_user_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "finisher_id"
    t.bigint "user_id"
    t.datetime "ended_at"
    t.datetime "started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "status"
    t.datetime "last_contacted_at"
    t.index ["finisher_id"], name: "index_assignments_on_finisher_id"
    t.index ["project_id"], name: "index_assignments_on_project_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "finisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["finisher_id"], name: "index_favorites_on_finisher_id"
    t.index ["product_id"], name: "index_favorites_on_product_id"
  end

  create_table "finishers", force: :cascade do |t|
    t.string "chosen_name"
    t.string "pronouns"
    t.bigint "user_id", null: false
    t.text "description", null: false
    t.text "admin_notes"
    t.datetime "approved_at"
    t.string "street"
    t.string "street_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.text "other_skills"
    t.string "dominant_hand"
    t.text "other_favorites"
    t.text "dislikes"
    t.text "social_media"
    t.boolean "can_publicize"
    t.boolean "no_smoke"
    t.boolean "no_cats"
    t.boolean "no_dogs"
    t.boolean "terms_of_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "joined_on"
    t.boolean "unavailable", default: false
    t.boolean "has_completed_profile", default: false
    t.boolean "has_taken_ownership_of_profile", default: false
    t.string "phone_number"
    t.float "latitude"
    t.float "longitude"
    t.string "in_home_pets"
    t.boolean "has_smoke_in_home", default: false
    t.string "workplace_name"
    t.boolean "has_workplace_match"
    t.string "emergency_contact_name"
    t.string "emergency_contact_phone_number"
    t.string "emergency_contact_email"
    t.string "emergency_contact_relation"
    t.boolean "has_volunteer_time_off"
    t.string "inbound_email_address"
    t.index ["inbound_email_address"], name: "index_finishers_on_inbound_email_address", unique: true
    t.index ["joined_on"], name: "index_finishers_on_joined_on"
    t.index ["latitude"], name: "index_finishers_on_latitude"
    t.index ["longitude"], name: "index_finishers_on_longitude"
    t.index ["user_id"], name: "index_finishers_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "description"
    t.string "messageable_type"
    t.bigint "messageable_id"
    t.integer "last_edited_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel"
    t.string "sgid"
    t.string "redirect_to"
    t.integer "click_count", default: 0, null: false
    t.boolean "single_use", default: false, null: false
    t.datetime "expires_at"
    t.index ["channel"], name: "index_messages_on_channel"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id"
    t.index ["sgid"], name: "index_messages_on_sgid"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_notes", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_notes_on_project_id"
    t.index ["user_id"], name: "index_project_notes_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "user_id"
    t.string "status", default: "drafted", null: false
    t.string "name", null: false
    t.text "description"
    t.string "street"
    t.string "street_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.string "craft_type"
    t.string "has_pattern"
    t.string "material_type"
    t.string "crafter_name"
    t.text "crafter_description"
    t.string "recipient_name"
    t.text "more_details"
    t.boolean "can_publicize"
    t.boolean "terms_of_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.string "in_home_pets"
    t.boolean "has_smoke_in_home", default: false
    t.boolean "no_smoke"
    t.boolean "no_cats"
    t.boolean "no_dogs"
    t.string "crafter_dominant_hand"
    t.float "latitude"
    t.float "longitude"
    t.bigint "manager_id"
    t.string "ready_status"
    t.string "in_process_status"
    t.boolean "joann_helped", default: false
    t.boolean "urgent", default: false
    t.boolean "influencer", default: false
    t.boolean "group_project", default: false
    t.boolean "press", default: false
    t.boolean "privacy_needed", default: false
    t.bigint "group_manager_id"
    t.string "press_region"
    t.string "press_outlet"
    t.boolean "can_use_first_name", default: false
    t.boolean "can_share_crafter_details", default: false
    t.text "material_brand"
    t.string "inbound_email_address"
    t.index ["group_manager_id"], name: "index_projects_on_group_manager_id"
    t.index ["inbound_email_address"], name: "index_projects_on_inbound_email_address", unique: true
    t.index ["latitude"], name: "index_projects_on_latitude"
    t.index ["longitude"], name: "index_projects_on_longitude"
    t.index ["manager_id"], name: "index_projects_on_manager_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "phone", default: "", null: false
    t.string "role", default: "user", null: false
    t.text "heard_about_us"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_project_manager"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "projects", "finishers", column: "group_manager_id"
  add_foreign_key "projects", "users", column: "manager_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
