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

ActiveRecord::Schema[7.0].define(version: 2025_01_26_210320) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "agencies", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 255
    t.string "url", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "archived_at", precision: nil
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
    t.index ["finisher_id"], name: "index_assignments_on_finisher_id"
    t.index ["project_id"], name: "index_assignments_on_project_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "client_goal_responses", id: :serial, force: :cascade do |t|
    t.integer "client_goal_id"
    t.datetime "taken_at", precision: nil
    t.integer "rating"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "client_goals", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.string "name", limit: 255
    t.string "lookup_respondent_code", limit: 255
    t.integer "position"
    t.integer "rating_low"
    t.integer "rating_high"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "client_measure_responses", id: :serial, force: :cascade do |t|
    t.integer "client_measure_id"
    t.integer "measure_question_id"
    t.integer "measure_question_answer_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "entered_value"
    t.index ["client_measure_id"], name: "index_client_measure_responses_on_client_measure_id"
    t.index ["measure_question_answer_id"], name: "index_client_measure_responses_on_measure_question_answer_id"
    t.index ["measure_question_id"], name: "index_client_measure_responses_on_measure_question_id"
  end

  create_table "client_measure_scales", id: :serial, force: :cascade do |t|
    t.integer "measure_scale_id"
    t.integer "measure_scale_range_id"
    t.integer "client_measure_id"
    t.float "score"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["client_measure_id"], name: "index_client_measure_scales_on_client_measure_id"
    t.index ["measure_scale_id"], name: "index_client_measure_scales_on_measure_scale_id"
    t.index ["measure_scale_range_id"], name: "index_client_measure_scales_on_measure_scale_range_id"
  end

  create_table "client_measures", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "measure_id"
    t.string "lookup_respondent_code", limit: 255
    t.datetime "taken_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "instance"
    t.boolean "scores_only", default: false
    t.index ["client_id"], name: "index_client_measures_on_client_id"
    t.index ["measure_id"], name: "index_client_measures_on_measure_id"
    t.index ["taken_at"], name: "index_client_measures_on_taken_at"
  end

  create_table "client_session_ebp_activities", id: :serial, force: :cascade do |t|
    t.integer "client_session_id"
    t.integer "ebp_session_activity_id"
    t.datetime "supervised_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["client_session_id"], name: "index_client_session_ebp_activities_on_client_session_id"
    t.index ["ebp_session_activity_id"], name: "index_client_session_ebp_activities_on_ebp_session_activity_id"
  end

  create_table "client_session_organization_activities", id: :serial, force: :cascade do |t|
    t.integer "client_session_id"
    t.integer "organization_session_activity_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["client_session_id"], name: "org_activity_session_index"
    t.index ["organization_session_activity_id"], name: "org_activity_index"
  end

  create_table "client_session_respondents", id: :serial, force: :cascade do |t|
    t.integer "client_session_id"
    t.string "respondent_code", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["client_session_id"], name: "index_client_session_respondents_on_client_session_id"
    t.index ["respondent_code"], name: "index_client_session_respondents_on_respondent_code"
  end

  create_table "client_sessions", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "ebp_id"
    t.integer "membership_id"
    t.date "treated_on"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "client_present", default: true, null: false
    t.text "notes"
    t.index ["client_id"], name: "index_client_sessions_on_client_id"
    t.index ["ebp_id"], name: "index_client_sessions_on_ebp_id"
    t.index ["membership_id"], name: "index_client_sessions_on_membership_id"
  end

  create_table "client_trainings", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "training_id"
    t.date "started_on"
    t.date "ended_on"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "client_views", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "user_id"
    t.string "type", limit: 255
    t.date "viewed_on"
    t.datetime "created_at", precision: nil
    t.integer "hits_count", default: 0
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "membership_id"
    t.integer "ebp_id"
    t.string "lookup_diagnosis_code", limit: 255
    t.string "lookup_clinical_target_code", limit: 255
    t.string "lookup_client_status_code", limit: 255
    t.string "identifier", limit: 255
    t.string "slug", limit: 255
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["archived_at"], name: "index_clients_on_archived_at"
    t.index ["ebp_id"], name: "index_clients_on_ebp_id"
    t.index ["identifier"], name: "index_clients_on_identifier"
    t.index ["membership_id"], name: "index_clients_on_membership_id"
    t.index ["organization_id"], name: "index_clients_on_organization_id"
  end

  create_table "consultant_evaluation_answers", id: :serial, force: :cascade do |t|
    t.integer "consultant_evaluation_question_id"
    t.string "name", limit: 255
    t.string "value", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["consultant_evaluation_question_id"], name: "index_consultant_evaluation_question_id"
  end

  create_table "consultant_evaluation_forms", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.datetime "archived_at", precision: nil
    t.text "description"
    t.boolean "has_client", default: true, null: false
    t.index ["organization_id"], name: "i_consultant_evaluation_form_organization"
  end

  create_table "consultant_evaluation_questions", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.text "description"
    t.string "ui_type", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "display_if", limit: 255
    t.string "code", limit: 255
    t.string "name", limit: 255
    t.string "data_type", limit: 255
    t.boolean "required", default: false, null: false
    t.boolean "listed", default: false, null: false
    t.text "section_header"
    t.integer "consultant_evaluation_form_id"
    t.index ["consultant_evaluation_form_id"], name: "i_consultant_evaluation_question_form"
    t.index ["organization_id"], name: "index_consultant_evaluation_questions_on_organization_id"
  end

  create_table "consultant_evaluation_responses", id: :serial, force: :cascade do |t|
    t.integer "consultant_evaluation_id"
    t.integer "consultant_evaluation_question_id"
    t.integer "consultant_evaluation_answer_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "entered_value", limit: 255
    t.index ["consultant_evaluation_answer_id"], name: "index_consultant_evaluation_response_answer_id"
    t.index ["consultant_evaluation_id"], name: "index_consultant_evaluation_response_note_id"
  end

  create_table "consultant_evaluations", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "training_consultant_id"
    t.integer "training_user_id"
    t.datetime "consulted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "consultant_evaluation_form_id"
    t.index ["client_id"], name: "index_consultant_evaluations_on_client_id"
    t.index ["consultant_evaluation_form_id"], name: "i_consultant_evaluation_form"
    t.index ["training_consultant_id"], name: "index_consultant_evaluations_on_training_consultant_id"
    t.index ["training_user_id"], name: "index_consultant_evaluations_on_training_user_id"
  end

  create_table "consultant_notes", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "training_consultant_id"
    t.integer "training_user_id"
    t.datetime "consulted_at", precision: nil
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["client_id"], name: "index_consultant_notes_on_client_id"
    t.index ["training_consultant_id"], name: "index_consultant_notes_on_training_consultant_id"
    t.index ["training_user_id"], name: "index_consultant_notes_on_training_user_id"
  end

  create_table "custom_field_answers", id: :serial, force: :cascade do |t|
    t.integer "custom_field_id"
    t.string "name", limit: 255
    t.string "value", limit: 255
    t.string "index", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "custom_field_responses", id: :serial, force: :cascade do |t|
    t.integer "custom_field_id"
    t.integer "client_id"
    t.text "encrypted_value"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "value"
  end

  create_table "custom_fields", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.text "description"
    t.integer "position"
    t.string "ui_type", limit: 255
    t.string "data_type", limit: 255
    t.boolean "required"
    t.boolean "listed"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "display_if", limit: 255
    t.string "code", limit: 255
    t.datetime "archived_at", precision: nil
    t.text "section_header"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "ebp_documents", id: :serial, force: :cascade do |t|
    t.integer "ebp_id"
    t.integer "position"
    t.boolean "restricted"
    t.string "name", limit: 255
    t.text "description"
    t.index ["ebp_id"], name: "index_ebp_documents_on_ebp_id"
  end

  create_table "ebp_session_activities", id: :serial, force: :cascade do |t|
    t.integer "ebp_id"
    t.integer "parent_id"
    t.string "name", limit: 255
    t.text "description"
    t.boolean "required_for_roster", default: false
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "primary", default: false, null: false
    t.boolean "default_displayed", default: false, null: false
    t.index ["ebp_id"], name: "index_ebp_session_activities_on_ebp_id"
  end

  create_table "ebp_users", id: :serial, force: :cascade do |t|
    t.integer "ebp_id"
    t.integer "user_id"
    t.boolean "roster_agreement_completed_at"
    t.boolean "roster_request_approved_at"
    t.index ["ebp_id"], name: "index_ebp_users_on_ebp_id"
    t.index ["user_id"], name: "index_ebp_users_on_user_id"
  end

  create_table "ebps", id: :serial, force: :cascade do |t|
    t.string "lookup_ebp_type_code", limit: 255
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.text "description"
    t.integer "min_sessions_per_case_count"
    t.integer "min_cases_count"
    t.text "roster_agreement"
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["archived_at"], name: "index_ebps_on_archived_at"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "direct_object_id"
    t.integer "indirect_object_id"
    t.string "type", limit: 255
    t.text "message"
    t.datetime "created_at", precision: nil
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
    t.index ["joined_on"], name: "index_finishers_on_joined_on"
    t.index ["latitude"], name: "index_finishers_on_latitude"
    t.index ["longitude"], name: "index_finishers_on_longitude"
    t.index ["user_id"], name: "index_finishers_on_user_id"
  end

  create_table "group_memberships", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "membership_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["membership_id"], name: "index_group_memberships_on_membership_id"
  end

  create_table "group_supervisors", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "membership_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["group_id"], name: "index_group_supervisors_on_group_id"
    t.index ["membership_id"], name: "index_group_supervisors_on_membership_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "membership_id"
    t.string "name", limit: 255
    t.text "description"
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["archived_at"], name: "index_groups_on_archived_at"
    t.index ["membership_id"], name: "index_groups_on_membership_id"
    t.index ["organization_id"], name: "index_groups_on_organization_id"
  end

  create_table "invoice_deliveries", id: :serial, force: :cascade do |t|
    t.integer "invoice_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "invoices", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.date "invoiced_on"
    t.integer "user_active_days_count"
    t.decimal "user_cost_per_day", precision: 8, scale: 2
    t.decimal "total_cost", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "users_count", default: 0
  end

  create_table "line_items", id: :serial, force: :cascade do |t|
    t.integer "invoice_id"
    t.string "name", limit: 255
    t.text "description"
    t.decimal "cost", precision: 8, scale: 2
    t.integer "count", default: 1, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "street_1", limit: 255
    t.string "street_2", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 255
    t.string "zip", limit: 255
    t.string "lat", limit: 255
    t.string "lon", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["lat", "lon"], name: "index_locations_on_lat_and_lon"
  end

  create_table "lookups", id: :serial, force: :cascade do |t|
    t.string "code", limit: 255
    t.string "name", limit: 255
    t.string "type", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["code"], name: "index_lookups_on_code"
    t.index ["type", "code"], name: "index_lookups_on_type_and_code"
  end

  create_table "measure_question_answers", id: :serial, force: :cascade do |t|
    t.integer "measure_question_id"
    t.text "name"
    t.integer "value"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["measure_question_id"], name: "index_measure_question_answers_on_measure_question_id"
  end

  create_table "measure_questions", id: :serial, force: :cascade do |t|
    t.integer "measure_id"
    t.text "description"
    t.string "ui_type", limit: 255
    t.string "display_if", limit: 255
    t.string "code", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "section_header"
    t.boolean "first_measure_only"
    t.text "name"
    t.string "data_type", limit: 255
    t.boolean "required", default: false, null: false
    t.boolean "listed", default: false, null: false
    t.integer "default_value"
    t.boolean "use_previous_value"
    t.string "display_name", limit: 255
    t.index ["measure_id"], name: "index_measure_questions_on_measure_id"
  end

  create_table "measure_scale_ranges", id: :serial, force: :cascade do |t|
    t.integer "measure_scale_id"
    t.string "name", limit: 255
    t.float "high"
    t.float "low"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["measure_scale_id"], name: "index_measure_scale_ranges_on_measure_scale_id"
  end

  create_table "measure_scales", id: :serial, force: :cascade do |t|
    t.integer "measure_id"
    t.string "name", limit: 255
    t.string "algorithm", limit: 255
    t.string "question_codes", limit: 255
    t.integer "max"
    t.float "clinical_threshold"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "primary", default: true, null: false
    t.index ["measure_id"], name: "index_measure_scales_on_measure_id"
  end

  create_table "measures", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "has_respondent", default: false, null: false
    t.integer "private_organization_id"
    t.text "instructions"
    t.boolean "numbered", default: false, null: false
    t.boolean "display_answer_values", default: false, null: false
    t.text "definitions"
    t.index ["code"], name: "index_measures_on_code"
  end

  create_table "membership_requests", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.datetime "processed_at", precision: nil
    t.string "membership_role", limit: 255
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.string "status", limit: 255
    t.string "role", limit: 255
    t.string "title", limit: 255
    t.string "phone", limit: 255
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["archived_at"], name: "index_memberships_on_archived_at"
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "targetable_id"
    t.string "targetable_type", limit: 255
    t.integer "user_id"
    t.text "subject"
    t.text "body"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["targetable_id", "targetable_type"], name: "index_messages_on_targetable_id_and_targetable_type"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "organization_ebp_documents", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "ebp_document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ebp_document_id"], name: "index_organization_ebp_documents_on_ebp_document_id"
    t.index ["organization_id"], name: "index_organization_ebp_documents_on_organization_id"
  end

  create_table "organization_lookups", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "code", limit: 255
    t.string "name", limit: 255
    t.string "type", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["code"], name: "index_organization_lookups_on_code"
    t.index ["type", "code"], name: "index_organization_lookups_on_type_and_code"
  end

  create_table "organization_measures", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "measure_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "client_measure_responses_report_generated_at", precision: nil
  end

  create_table "organization_report_rows", id: :serial, force: :cascade do |t|
    t.integer "organization_report_id"
    t.json "fields", default: [], null: false
    t.datetime "created_at", precision: nil
  end

  create_table "organization_reports", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.string "slug"
    t.string "status"
    t.integer "duration"
    t.datetime "last_build_at", precision: nil
    t.json "fields", default: [], null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "organization_session_activities", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.text "description"
    t.boolean "required_for_roster", default: false
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["organization_id"], name: "index_organization_session_activities_on_organization_id"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug", limit: 255
    t.string "encrypted_field_key", limit: 255
    t.string "phone", limit: 255
    t.string "street1", limit: 255
    t.string "street2", limit: 255
    t.string "city", limit: 255
    t.string "state", limit: 255
    t.string "zip", limit: 255
    t.integer "user_id"
    t.string "url", limit: 255
    t.text "email"
    t.boolean "display_session_activity_children", default: false, null: false
    t.text "invoices_email"
    t.text "invoices_address"
    t.boolean "display_measure_instance", default: false, null: false
    t.index ["archived_at"], name: "index_organizations_on_archived_at"
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
    t.index ["group_manager_id"], name: "index_projects_on_group_manager_id"
    t.index ["latitude"], name: "index_projects_on_latitude"
    t.index ["longitude"], name: "index_projects_on_longitude"
    t.index ["manager_id"], name: "index_projects_on_manager_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "roster_requests", id: :serial, force: :cascade do |t|
    t.integer "ebp_id"
    t.integer "user_id"
    t.integer "supervisor_id"
    t.integer "consultant_id"
    t.datetime "supervisor_reviewed_at", precision: nil
    t.datetime "consultant_reviewed_at", precision: nil
    t.boolean "supervisor_approved", default: false
    t.boolean "consultant_approved", default: false
    t.index ["consultant_id"], name: "index_roster_requests_on_consultant_id"
    t.index ["ebp_id"], name: "index_roster_requests_on_ebp_id"
    t.index ["supervisor_id"], name: "index_roster_requests_on_supervisor_id"
    t.index ["user_id"], name: "index_roster_requests_on_user_id"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "location_id"
    t.string "name", limit: 255
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["location_id"], name: "index_sites_on_location_id"
    t.index ["organization_id"], name: "index_sites_on_organization_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "organization_id"
    t.datetime "end_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["organization_id"], name: "index_subscriptions_on_organization_id"
    t.index ["product_id"], name: "index_subscriptions_on_product_id"
  end

  create_table "suggested_organizations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 255
    t.string "url", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "membership_role", limit: 255
    t.integer "organization_id"
    t.string "city", limit: 255
    t.string "state", limit: 255
  end

  create_table "supervisor_evaluation_answers", id: :serial, force: :cascade do |t|
    t.integer "supervisor_evaluation_question_id"
    t.string "name", limit: 255
    t.string "value", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["supervisor_evaluation_question_id"], name: "index_supervisor_evaluation_question_id"
  end

  create_table "supervisor_evaluation_questions", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.text "description"
    t.string "ui_type", limit: 255
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "display_if", limit: 255
    t.string "code", limit: 255
    t.string "name", limit: 255
    t.string "data_type", limit: 255
    t.boolean "required", default: false, null: false
    t.boolean "listed", default: false, null: false
    t.text "section_header"
    t.index ["organization_id"], name: "index_supervisor_evaluation_questions_on_organization_id"
  end

  create_table "supervisor_evaluation_responses", id: :serial, force: :cascade do |t|
    t.integer "supervisor_evaluation_id"
    t.integer "supervisor_evaluation_question_id"
    t.integer "supervisor_evaluation_answer_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "entered_value", limit: 255
    t.index ["supervisor_evaluation_answer_id"], name: "index_supervisor_evaluation_response_answer_id"
    t.index ["supervisor_evaluation_id"], name: "index_supervisor_evaluation_response_note_id"
  end

  create_table "supervisor_evaluations", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "supervisor_id"
    t.integer "provider_id"
    t.datetime "supervised_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["client_id"], name: "index_supervisor_evaluations_on_client_id"
    t.index ["provider_id"], name: "index_supervisor_evaluations_on_provider_id"
    t.index ["supervisor_id"], name: "index_supervisor_evaluations_on_supervisor_id"
  end

  create_table "supervisor_notes", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "supervisor_id"
    t.integer "provider_id"
    t.datetime "supervised_at", precision: nil
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["client_id"], name: "index_supervisor_notes_on_client_id"
    t.index ["provider_id"], name: "index_supervisor_notes_on_provider_id"
    t.index ["supervisor_id"], name: "index_supervisor_notes_on_supervisor_id"
  end

  create_table "training_admins", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.integer "user_id"
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "training_completion_requirements", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.string "name", limit: 255
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "training_consultants", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "archived_at", precision: nil
    t.index ["training_id"], name: "index_training_consultants_on_training_id"
    t.index ["user_id"], name: "index_training_consultants_on_user_id"
  end

  create_table "training_ebp_session_activities", id: :serial, force: :cascade do |t|
    t.integer "training_ebp_id"
    t.integer "ebp_session_activity_id"
    t.boolean "displayed", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["ebp_session_activity_id"], name: "by_session_activity"
    t.index ["training_ebp_id"], name: "by_training_ebp"
  end

  create_table "training_ebps", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.integer "ebp_id"
    t.integer "min_sessions_per_case_count"
    t.integer "min_cases_count"
    t.index ["ebp_id"], name: "index_training_ebps_on_ebp_id"
    t.index ["training_id"], name: "index_training_ebps_on_training_id"
  end

  create_table "training_group_call_users", id: :serial, force: :cascade do |t|
    t.integer "training_group_call_id"
    t.integer "client_id"
    t.boolean "attended", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "training_user_id"
    t.datetime "reminder_sent_at", precision: nil
    t.index ["training_user_id"], name: "index_training_group_call_users_on_training_user_id"
  end

  create_table "training_group_calls", id: :serial, force: :cascade do |t|
    t.integer "training_group_id"
    t.date "called_on"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "note"
    t.text "description"
  end

  create_table "training_group_consultants", id: :serial, force: :cascade do |t|
    t.integer "training_group_id"
    t.integer "training_consultant_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "primary", default: false, null: false
    t.index ["training_consultant_id"], name: "index_training_group_consultants_on_training_consultant_id"
    t.index ["training_group_id"], name: "index_training_group_consultants_on_training_group_id"
  end

  create_table "training_group_users", id: :serial, force: :cascade do |t|
    t.integer "training_group_id"
    t.integer "training_user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["training_group_id"], name: "index_training_group_users_on_training_group_id"
    t.index ["training_user_id"], name: "index_training_group_users_on_training_user_id"
  end

  create_table "training_groups", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.string "name", limit: 255
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["training_id"], name: "index_training_groups_on_training_id"
  end

  create_table "training_measures", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.integer "measure_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "training_requests", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.integer "user_id"
    t.datetime "processed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "role", limit: 255
    t.index ["training_id"], name: "index_training_requests_on_training_id"
    t.index ["user_id"], name: "index_training_requests_on_user_id"
  end

  create_table "training_user_accomplishments", id: :serial, force: :cascade do |t|
    t.integer "training_completion_requirement_id"
    t.integer "training_user_id"
    t.date "accomplished_on"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "training_users", id: :serial, force: :cascade do |t|
    t.integer "training_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "archived_at", precision: nil
    t.date "completed_on"
    t.string "supervisor_name", limit: 255
    t.string "supervisor_email", limit: 255
    t.string "archive_reason", limit: 255
    t.string "participant_id", limit: 255
    t.text "upload_url"
    t.index ["training_id"], name: "index_training_users_on_training_id"
    t.index ["user_id"], name: "index_training_users_on_user_id"
  end

  create_table "trainings", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "location_id"
    t.string "name", limit: 255
    t.text "description"
    t.datetime "start_at", precision: nil
    t.datetime "end_at", precision: nil
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "participant_code", limit: 255
    t.string "consultant_code", limit: 255
    t.string "slug", limit: 255
    t.boolean "display_session_activity_children", default: false, null: false
    t.integer "consultant_evaluation_form_id"
    t.boolean "send_reminders", default: false, null: false
    t.integer "reminder_lead_days", default: 2
    t.integer "min_calls_required", default: 9
    t.text "instructions"
    t.boolean "activate_client_goals", default: false, null: false
    t.string "short_name", limit: 255
    t.string "share_clients", limit: 255
    t.boolean "published", default: true, null: false
    t.integer "consultant_completion_form_id"
    t.index ["archived_at"], name: "index_trainings_on_archived_at"
    t.index ["consultant_completion_form_id"], name: "i_training_consultant_completion_form"
    t.index ["consultant_evaluation_form_id"], name: "i_training_consultant_evaluation_form"
    t.index ["location_id"], name: "index_trainings_on_location_id"
    t.index ["organization_id"], name: "index_trainings_on_organization_id"
  end

  create_table "user_active_days", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.date "active_on"
  end

  create_table "user_messages", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "message_id"
    t.datetime "read_at", precision: nil
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["message_id"], name: "index_user_messages_on_message_id"
    t.index ["user_id"], name: "index_user_messages_on_user_id"
  end

  create_table "user_questions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "question", limit: 255
    t.text "response"
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "projects", "finishers", column: "group_manager_id"
  add_foreign_key "projects", "users", column: "manager_id"
end
