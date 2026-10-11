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

ActiveRecord::Schema[8.1].define(version: 2026_10_11_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "pricing_types", ["fixed", "per_person"]

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bus_quotes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bus_trip_id", null: false
    t.string "company", null: false
    t.datetime "created_at", null: false
    t.jsonb "prices", default: {}, null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["bus_trip_id"], name: "index_bus_quotes_on_bus_trip_id"
    t.index ["wedding_id"], name: "index_bus_quotes_on_wedding_id"
  end

  create_table "bus_trips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "index_bus_trips_on_wedding_id"
  end

  create_table "buses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "seats", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "index_buses_on_wedding_id"
    t.check_constraint "seats > 0", name: "positive_seats"
  end

  create_table "cost_centers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "index_cost_centers_on_wedding_id"
  end

  create_table "engine_stats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "evaluation_count", null: false
    t.integer "iteration", null: false
    t.float "real_time", null: false
    t.float "system_time", null: false
    t.uuid "tables_arrangement_id", null: false
    t.float "total_time", null: false
    t.datetime "updated_at", null: false
    t.float "user_time", null: false
    t.index ["tables_arrangement_id", "iteration"], name: "index_engine_stats_on_tables_arrangement_id_and_iteration", unique: true
  end

  create_table "event_attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wedding_id", null: false
    t.uuid "guest_id", null: false
    t.uuid "wedding_event_id", null: false
    t.string "status", default: "invited", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guest_id", "wedding_event_id"], name: "index_event_attendances_on_guest_id_and_wedding_event_id", unique: true
    t.index ["guest_id"], name: "index_event_attendances_on_guest_id"
    t.index ["wedding_event_id"], name: "index_event_attendances_on_wedding_event_id"
    t.index ["wedding_id"], name: "index_event_attendances_on_wedding_id"
  end

  create_table "expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.enum "pricing_type", default: "fixed", null: false, enum_type: "pricing_types"
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.uuid "wedding_event_id"
    t.string "category"
    t.integer "lock_version", default: 0, null: false
    t.index ["wedding_event_id"], name: "index_expenses_on_wedding_event_id"
    t.index ["wedding_id"], name: "index_expenses_on_wedding_id"
    t.check_constraint "amount > 0::numeric", name: "check_positive_amount"
  end

  create_table "group_affinities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.float "discomfort", null: false
    t.uuid "group_a_id", null: false
    t.uuid "group_b_id", null: false
    t.datetime "updated_at", null: false
    t.index "LEAST(group_a_id, group_b_id), GREATEST(group_a_id, group_b_id)", name: "uindex_group_pair", unique: true
    t.index ["group_a_id"], name: "index_group_affinities_on_group_a_id"
    t.index ["group_b_id"], name: "index_group_affinities_on_group_b_id"
    t.check_constraint "discomfort >= 0::double precision AND discomfort <= 2::double precision", name: "check_valid_discomfort"
    t.check_constraint "group_a_id <> group_b_id", name: "check_distinct_groups"
  end

  create_table "groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "name", null: false
    t.integer "order", default: 1, null: false
    t.uuid "parent_id"
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["parent_id"], name: "index_groups_on_parent_id"
    t.index ["wedding_id", "name"], name: "index_groups_on_wedding_id_and_name", unique: true
  end

  create_table "guests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "group_id"
    t.uuid "invitation_id"
    t.integer "invitation_order"
    t.integer "menu_choice"
    t.uuid "menu_option_id"
    t.text "menu_restrictions"
    t.string "name", null: false
    t.boolean "needs_bus", default: true, null: false
    t.string "special_requests"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.string "email"
    t.string "phone"
    t.string "side", default: "Both", null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["group_id"], name: "index_guests_on_group_id"
    t.index ["invitation_id", "invitation_order"], name: "index_guests_on_invitation_id_and_invitation_order", unique: true
    t.index ["menu_option_id"], name: "index_guests_on_menu_option_id"
    t.index ["wedding_id"], name: "index_guests_on_wedding_id"
    t.check_constraint "(invitation_id IS NOT NULL) = (invitation_order IS NOT NULL)", name: "invitation_order_consistency"
  end

  create_table "invitation_configs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "qr_color", default: "#000000", null: false
    t.string "qr_fill_color"
    t.point "qr_position", default: [0.0, 0.0], null: false
    t.integer "qr_size_px", default: 250, null: false
    t.uuid "settings_id", null: false
    t.string "text_align", default: "left", null: false
    t.string "text_color", default: "#000000", null: false
    t.string "text_font_family", default: "Arial", null: false
    t.integer "text_font_size", default: 20, null: false
    t.integer "text_font_weight", limit: 2, default: 400, null: false
    t.point "text_position", default: [0.0, 300.0], null: false
    t.datetime "updated_at", null: false
    t.index ["settings_id"], name: "index_invitation_configs_on_settings_id", unique: true
    t.check_constraint "qr_color IS NULL OR qr_color::text ~* '^#[a-fA-F0-9]{6}$'::text", name: "hex_qr_color"
    t.check_constraint "qr_fill_color IS NULL OR qr_fill_color::text ~* '^#[a-fA-F0-9]{6}$'::text", name: "hex_qr_fill_color"
    t.check_constraint "qr_position[0] >= 0::double precision AND qr_position[1] >= 0::double precision", name: "qr_position_positive"
    t.check_constraint "qr_size_px >= 50", name: "qr_size_limits"
    t.check_constraint "text_align::text = ANY (ARRAY['left'::character varying::text, 'right'::character varying::text, 'center'::character varying::text])", name: "text_align_options"
    t.check_constraint "text_color IS NULL OR text_color::text ~* '^#[a-fA-F0-9]{6}$'::text", name: "hex_text_color"
    t.check_constraint "text_font_size >= 0", name: "font_size_positive"
    t.check_constraint "text_font_weight >= 100 AND text_font_weight <= 900 AND (text_font_weight::integer % 100) = 0", name: "text_font_weight"
    t.check_constraint "text_position[0] >= 0::double precision AND text_position[1] >= 0::double precision", name: "text_position_positive"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "index_invitations_on_wedding_id"
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "label", null: false
    t.decimal "latitude", null: false
    t.decimal "longitude", null: false
    t.bigint "place_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "index_locations_on_wedding_id"
    t.check_constraint "latitude >= '-90'::integer::numeric AND latitude <= 90::numeric", name: "latitude_range"
    t.check_constraint "longitude >= '-180'::integer::numeric AND longitude <= 180::numeric", name: "longitude_range"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "confirmation_token"
    t.datetime "confirmation_token_expires_at", precision: nil
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "wedding_id", null: false
    t.index ["confirmation_token"], name: "index_memberships_on_confirmation_token", unique: true
    t.index ["user_id", "wedding_id"], name: "index_memberships_on_user_id_and_wedding_id", unique: true
    t.index ["wedding_id"], name: "index_memberships_on_wedding_id"
  end

  create_table "menu_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "i18n_key"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "index_menu_options_on_wedding_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.bigint "resource_owner_id", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in"
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.bigint "resource_owner_id"
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "owner_id", null: false
    t.string "owner_type", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.uuid "cost_center_id"
    t.datetime "created_at", null: false
    t.uuid "expense_id", null: false
    t.date "paid_on"
    t.string "title"
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["cost_center_id"], name: "index_payments_on_cost_center_id"
    t.index ["expense_id"], name: "index_payments_on_expense_id"
    t.index ["wedding_id"], name: "index_payments_on_wedding_id"
  end

  create_table "planner_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wedding_id", null: false
    t.uuid "task_id"
    t.uuid "planner_vendor_id"
    t.uuid "uploaded_by_id", null: false
    t.string "file_name", null: false
    t.string "content_type", null: false
    t.integer "byte_size", null: false
    t.binary "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["planner_vendor_id"], name: "index_planner_documents_on_planner_vendor_id"
    t.index ["task_id"], name: "index_planner_documents_on_task_id"
    t.index ["uploaded_by_id"], name: "index_planner_documents_on_uploaded_by_id"
    t.index ["wedding_id"], name: "index_planner_documents_on_wedding_id"
    t.check_constraint "((task_id IS NOT NULL)::integer + (planner_vendor_id IS NOT NULL)::integer) = 1", name: "planner_documents_one_parent"
    t.check_constraint "byte_size > 0 AND byte_size <= 3145728 AND octet_length(data) = byte_size", name: "planner_documents_valid_size"
  end

  create_table "planner_vendors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wedding_id", null: false
    t.uuid "wedding_event_id"
    t.string "name", null: false
    t.string "category"
    t.string "contact"
    t.string "status", default: "Shortlisted", null: false
    t.text "notes"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wedding_event_id"], name: "index_planner_vendors_on_wedding_event_id"
    t.index ["wedding_id"], name: "index_planner_vendors_on_wedding_id"
  end

  create_table "seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "guest_id", null: false
    t.boolean "pinned", default: false, null: false
    t.uuid "table_id", null: false
    t.uuid "tables_arrangement_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["guest_id"], name: "index_seats_on_guest_id"
    t.index ["table_id"], name: "index_seats_on_table_id"
    t.index ["tables_arrangement_id"], name: "index_seats_on_tables_arrangement_id"
    t.index ["wedding_id"], name: "index_seats_on_wedding_id"
  end

  create_table "settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "bus_management", default: false, null: false
    t.datetime "created_at", null: false
    t.date "date"
    t.boolean "display_menu_choices", default: true, null: false
    t.string "engine_message_broker", default: "sidekiq", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.string "partner_one"
    t.string "partner_two"
    t.string "venue"
    t.string "currency", default: "INR", null: false
    t.decimal "budget", precision: 14, scale: 2, default: "0.0", null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["wedding_id"], name: "index_settings_on_wedding_id", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "table_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "availability", limit: 2
    t.int4range "capacity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "index_table_types_on_wedding_id"
    t.check_constraint "availability IS NULL OR availability > 0", name: "availability_positive_or_null"
    t.check_constraint "lower(capacity) > 0 AND upper(capacity) >= lower(capacity)", name: "capacity_bounds_positive"
  end

  create_table "tables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.int4range "capacity", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "number", null: false
    t.uuid "tables_arrangement_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["tables_arrangement_id"], name: "index_tables_on_tables_arrangement_id"
    t.index ["wedding_id", "tables_arrangement_id", "number"], name: "index_tables_on_wedding_id_and_number", unique: true
    t.check_constraint "lower(capacity) > 0 AND upper(capacity) >= lower(capacity)", name: "capacity_bounds_positive"
    t.check_constraint "number > 0", name: "number_positive"
  end

  create_table "tables_arrangements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "digest", default: -> { "gen_random_uuid()" }, null: false
    t.float "discomfort"
    t.boolean "editable", default: false, null: false
    t.string "name", default: "nameless"
    t.integer "optimized_version", default: 0, null: false
    t.float "progress", default: 0.0, null: false
    t.string "status", default: "not_started", null: false
    t.boolean "system", default: true, null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.index ["wedding_id"], name: "uindex_tables_arrangements_on_wedding_id", unique: true
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.uuid "wedding_id", null: false
    t.uuid "wedding_event_id"
    t.date "due_date"
    t.string "assignee"
    t.string "priority", default: "Normal", null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["wedding_event_id"], name: "index_tasks_on_wedding_event_id"
    t.index ["wedding_id"], name: "index_tasks_on_wedding_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "language"
    t.datetime "last_sign_in_at"
    t.datetime "locked_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "superadmin", default: false, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.uuid "wedding_id"
    t.string "google_subject"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_subject"], name: "index_users_on_google_subject", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["wedding_id"], name: "index_users_on_wedding_id"
    t.check_constraint "language IS NULL OR length(language::text) = 2", name: "iso639_1_length_language"
  end

  create_table "websites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "domain"
    t.jsonb "pages", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.string "version", default: "v2.0", null: false
    t.uuid "wedding_id", null: false
    t.index "lower((domain)::text)", name: "uindex_websites_on_lower_domain", unique: true
    t.index ["wedding_id"], name: "index_websites_on_wedding_id", unique: true
  end

  create_table "wedding_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wedding_id", null: false
    t.string "name", null: false
    t.date "date", null: false
    t.string "start_time"
    t.string "venue"
    t.text "notes"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wedding_id"], name: "index_wedding_events_on_wedding_id"
  end

  create_table "weddings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "deletion_token"
    t.timestamptz "deletion_token_expires_at"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_weddings_on_slug", unique: true
    t.check_constraint "deletion_token IS NULL AND deletion_token_expires_at IS NULL OR deletion_token IS NOT NULL AND deletion_token_expires_at IS NOT NULL", name: "chk_rails_deletion_token_consistency"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bus_quotes", "bus_trips", on_delete: :cascade
  add_foreign_key "bus_quotes", "weddings", on_delete: :cascade
  add_foreign_key "bus_trips", "weddings", on_delete: :cascade
  add_foreign_key "buses", "weddings", on_delete: :cascade
  add_foreign_key "cost_centers", "weddings", on_delete: :cascade
  add_foreign_key "engine_stats", "tables_arrangements", on_delete: :cascade
  add_foreign_key "event_attendances", "guests", on_delete: :cascade
  add_foreign_key "event_attendances", "wedding_events", on_delete: :cascade
  add_foreign_key "event_attendances", "weddings", on_delete: :cascade
  add_foreign_key "expenses", "wedding_events", on_delete: :nullify
  add_foreign_key "expenses", "weddings", on_delete: :cascade
  add_foreign_key "group_affinities", "groups", column: "group_a_id", name: "fk_rails_group_a_id", on_delete: :cascade
  add_foreign_key "group_affinities", "groups", column: "group_b_id", name: "fk_rails_group_b_id", on_delete: :cascade
  add_foreign_key "groups", "groups", column: "parent_id", on_delete: :nullify
  add_foreign_key "groups", "weddings", on_delete: :cascade
  add_foreign_key "guests", "groups"
  add_foreign_key "guests", "invitations"
  add_foreign_key "guests", "menu_options", on_delete: :nullify
  add_foreign_key "guests", "weddings", on_delete: :cascade
  add_foreign_key "invitation_configs", "settings", column: "settings_id", on_delete: :cascade
  add_foreign_key "invitations", "weddings", on_delete: :cascade
  add_foreign_key "locations", "weddings", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "memberships", "weddings", on_delete: :cascade
  add_foreign_key "menu_options", "weddings", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "payments", "cost_centers", on_delete: :nullify
  add_foreign_key "payments", "expenses", on_delete: :cascade
  add_foreign_key "payments", "weddings", on_delete: :cascade
  add_foreign_key "planner_documents", "planner_vendors", on_delete: :cascade
  add_foreign_key "planner_documents", "tasks", on_delete: :cascade
  add_foreign_key "planner_documents", "users", column: "uploaded_by_id"
  add_foreign_key "planner_documents", "weddings", on_delete: :cascade
  add_foreign_key "planner_vendors", "wedding_events", on_delete: :nullify
  add_foreign_key "planner_vendors", "weddings", on_delete: :cascade
  add_foreign_key "seats", "guests", on_delete: :cascade
  add_foreign_key "seats", "tables", on_delete: :cascade
  add_foreign_key "seats", "tables_arrangements", on_delete: :cascade
  add_foreign_key "seats", "weddings", on_delete: :cascade
  add_foreign_key "settings", "weddings", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "table_types", "weddings", on_delete: :cascade
  add_foreign_key "tables", "tables_arrangements", on_delete: :cascade
  add_foreign_key "tables", "weddings", on_delete: :cascade
  add_foreign_key "tables_arrangements", "weddings", on_delete: :cascade
  add_foreign_key "tasks", "wedding_events", on_delete: :nullify
  add_foreign_key "tasks", "weddings", on_delete: :cascade
  add_foreign_key "users", "weddings", on_delete: :cascade
  add_foreign_key "websites", "weddings", on_delete: :cascade
  add_foreign_key "wedding_events", "weddings", on_delete: :cascade
end
