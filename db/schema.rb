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

ActiveRecord::Schema.define(version: 2020_05_15_110709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "announcement_recipients", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "announcement_id"
    t.index ["announcement_id"], name: "index_announcement_recipients_on_announcement_id"
    t.index ["user_id"], name: "index_announcement_recipients_on_user_id"
  end

  create_table "announcements", id: :serial, force: :cascade do |t|
    t.string "title_ru"
    t.string "reply_to"
    t.text "body_ru"
    t.string "attachment"
    t.boolean "is_special"
    t.string "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.string "title_en"
    t.text "body_en"
    t.index ["created_by_id"], name: "index_announcements_on_created_by_id"
  end

  create_table "api_access_keys", id: :serial, force: :cascade do |t|
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_access_keys_exports", id: :serial, force: :cascade do |t|
    t.integer "access_key_id"
    t.integer "export_id"
  end

  create_table "api_exports", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "request"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text"
    t.boolean "safe", default: true
  end

  create_table "api_exports_key_parameters", id: false, force: :cascade do |t|
    t.integer "export_id"
    t.integer "key_parameter_id"
  end

  create_table "api_key_parameters", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_values", id: :serial, force: :cascade do |t|
    t.integer "options_category_id"
    t.string "value_ru"
    t.string "value_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["options_category_id"], name: "index_category_values_on_options_category_id"
  end

  create_table "comments_comments", id: :serial, force: :cascade do |t|
    t.text "text"
    t.string "attachable_type", null: false
    t.integer "attachable_id", null: false
    t.integer "user_id", null: false
    t.integer "context_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_comments_comments_on_attachable_type_and_attachable_id"
    t.index ["context_id"], name: "index_comments_comments_on_context_id"
    t.index ["user_id"], name: "index_comments_comments_on_user_id"
  end

  create_table "comments_context_groups", id: :serial, force: :cascade do |t|
    t.integer "context_id", null: false
    t.integer "group_id", null: false
    t.integer "type_ab", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context_id"], name: "index_comments_context_groups_on_context_id"
    t.index ["group_id"], name: "index_comments_context_groups_on_group_id"
  end

  create_table "comments_contexts", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_en"
  end

  create_table "comments_file_attachments", id: :serial, force: :cascade do |t|
    t.string "file"
    t.text "description"
    t.string "attachable_type", null: false
    t.integer "attachable_id", null: false
    t.integer "user_id", null: false
    t.integer "context_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_id", "attachable_type"], name: "attach_index"
    t.index ["context_id"], name: "index_comments_file_attachments_on_context_id"
    t.index ["user_id"], name: "index_comments_file_attachments_on_user_id"
  end

  create_table "comments_group_classes", id: :serial, force: :cascade do |t|
    t.string "class_name"
    t.integer "obj_id"
    t.integer "group_id"
    t.boolean "allow", null: false
    t.integer "type_ab", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_comments_group_classes_on_group_id"
  end

  create_table "comments_taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "attachable_type", null: false
    t.integer "attachable_id", null: false
    t.integer "user_id"
    t.integer "context_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_comments_taggings_on_attachable_type_and_attachable_id"
    t.index ["context_id"], name: "index_comments_taggings_on_context_id"
    t.index ["tag_id", "attachable_id", "attachable_type", "context_id"], name: "att_contex_index", unique: true
    t.index ["user_id"], name: "index_comments_taggings_on_user_id"
  end

  create_table "comments_tags", id: :serial, force: :cascade do |t|
    t.string "name"
  end

  create_table "core_access_fields", id: :serial, force: :cascade do |t|
    t.integer "access_id"
    t.integer "quota"
    t.integer "used", default: 0
    t.integer "quota_kind_id"
    t.index ["access_id"], name: "index_core_access_fields_on_access_id"
  end

  create_table "core_accesses", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "cluster_id", null: false
    t.string "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "project_group_name"
    t.index ["cluster_id"], name: "index_core_accesses_on_cluster_id"
    t.index ["project_id", "cluster_id"], name: "index_core_accesses_on_project_id_and_cluster_id", unique: true
    t.index ["project_id"], name: "index_core_accesses_on_project_id"
  end

  create_table "core_bot_links", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_core_bot_links_on_user_id"
  end

  create_table "core_cities", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.string "title_ru"
    t.string "title_en"
    t.boolean "checked", default: false
    t.index ["country_id"], name: "index_core_cities_on_country_id"
    t.index ["title_ru"], name: "index_core_cities_on_title_ru"
  end

  create_table "core_cluster_logs", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.text "message", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "project_id"
    t.index ["cluster_id"], name: "index_core_cluster_logs_on_cluster_id"
    t.index ["project_id"], name: "index_core_cluster_logs_on_project_id"
  end

  create_table "core_cluster_quotas", id: :serial, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "value"
    t.integer "quota_kind_id"
    t.index ["cluster_id"], name: "index_core_cluster_quotas_on_cluster_id"
  end

  create_table "core_clusters", id: :serial, force: :cascade do |t|
    t.string "name_ru", null: false
    t.string "host", null: false
    t.text "description"
    t.text "public_key"
    t.text "private_key"
    t.string "admin_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "available_for_work", default: true
    t.string "name_en"
    t.index ["private_key"], name: "index_core_clusters_on_private_key", unique: true
    t.index ["public_key"], name: "index_core_clusters_on_public_key", unique: true
  end

  create_table "core_countries", id: :serial, force: :cascade do |t|
    t.string "title_ru"
    t.string "title_en"
    t.boolean "checked", default: false
  end

  create_table "core_credentials", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "state"
    t.string "name", null: false
    t.text "public_key", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_core_credentials_on_user_id"
  end

  create_table "core_critical_technologies", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
  end

  create_table "core_critical_technologies_per_projects", id: :serial, force: :cascade do |t|
    t.integer "critical_technology_id"
    t.integer "project_id"
    t.index ["critical_technology_id"], name: "icrittechs_on_critical_technologies_per_projects"
    t.index ["project_id"], name: "iprojects_on_critical_technologies_per_projects"
  end

  create_table "core_department_mergers", id: :serial, force: :cascade do |t|
    t.integer "source_department_id"
    t.integer "to_organization_id"
    t.integer "to_department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "core_direction_of_sciences", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
  end

  create_table "core_direction_of_sciences_per_projects", id: :serial, force: :cascade do |t|
    t.integer "direction_of_science_id"
    t.integer "project_id"
    t.index ["direction_of_science_id"], name: "idos_on_dos_per_projects"
    t.index ["project_id"], name: "iproject_on_dos_per_projects"
  end

  create_table "core_employment_position_fields", id: :serial, force: :cascade do |t|
    t.integer "employment_position_name_id"
    t.string "name_ru"
    t.string "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "core_employment_position_names", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.text "autocomplete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
  end

  create_table "core_employment_positions", id: :serial, force: :cascade do |t|
    t.integer "employment_id"
    t.string "name"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "employment_position_name_id"
    t.integer "field_id"
    t.index ["employment_id"], name: "index_core_employment_positions_on_employment_id"
  end

  create_table "core_employments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.boolean "primary"
    t.string "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "organization_department_id"
    t.index ["organization_department_id"], name: "index_core_employments_on_organization_department_id"
  end

  create_table "core_group_of_research_areas", force: :cascade do |t|
    t.string "name_en"
    t.string "name_ru"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "core_members", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.boolean "owner", default: false
    t.string "login"
    t.string "project_access_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "organization_id"
    t.integer "organization_department_id"
    t.index ["organization_id"], name: "index_core_members_on_organization_id"
    t.index ["owner", "user_id", "project_id"], name: "index_core_members_on_owner_and_user_id_and_project_id"
    t.index ["project_access_state"], name: "index_core_members_on_project_access_state"
    t.index ["project_id"], name: "index_core_members_on_project_id"
    t.index ["user_id", "owner"], name: "index_core_members_on_user_id_and_owner"
    t.index ["user_id", "project_id"], name: "index_core_members_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_core_members_on_user_id"
  end

  create_table "core_notice_show_options", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "notice_id"
    t.boolean "hidden", default: false, null: false
    t.boolean "resolved", default: false, null: false
    t.string "answer"
    t.index ["notice_id"], name: "index_core_notice_show_options_on_notice_id"
    t.index ["user_id"], name: "index_core_notice_show_options_on_user_id"
  end

  create_table "core_notices", id: :serial, force: :cascade do |t|
    t.string "sourceable_type"
    t.integer "sourceable_id"
    t.string "linkable_type"
    t.integer "linkable_id"
    t.text "message"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category"
    t.string "kind"
    t.datetime "show_from"
    t.datetime "show_till"
    t.integer "active"
    t.index ["linkable_type", "linkable_id"], name: "index_core_notices_on_linkable_type_and_linkable_id"
    t.index ["sourceable_type", "sourceable_id"], name: "index_core_notices_on_sourceable_type_and_sourceable_id"
  end

  create_table "core_organization_departments", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.boolean "checked", default: false
    t.index ["organization_id"], name: "index_core_organization_departments_on_organization_id"
  end

  create_table "core_organization_kinds", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.boolean "departments_required", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
  end

  create_table "core_organizations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.integer "kind_id"
    t.integer "country_id"
    t.integer "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "checked", default: false
    t.index ["city_id"], name: "index_core_organizations_on_city_id"
    t.index ["country_id"], name: "index_core_organizations_on_country_id"
    t.index ["kind_id"], name: "index_core_organizations_on_kind_id"
  end

  create_table "core_partitions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "cluster_id"
    t.string "resources"
    t.index ["cluster_id"], name: "index_core_partitions_on_cluster_id"
  end

  create_table "core_project_cards", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.text "name"
    t.text "en_name"
    t.text "driver"
    t.text "en_driver"
    t.text "strategy"
    t.text "en_strategy"
    t.text "objective"
    t.text "en_objective"
    t.text "impact"
    t.text "en_impact"
    t.text "usage"
    t.text "en_usage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_core_project_cards_on_project_id"
  end

  create_table "core_project_invitations", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "user_fio", null: false
    t.string "user_email", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "language", default: "ru"
    t.index ["project_id"], name: "index_core_project_invitations_on_project_id"
  end

  create_table "core_project_kinds", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "name_en"
  end

  create_table "core_projects", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "organization_id"
    t.integer "organization_department_id"
    t.integer "kind_id"
    t.datetime "first_activation_at"
    t.datetime "finished_at"
    t.datetime "estimated_finish_date"
    t.index ["kind_id"], name: "index_core_projects_on_kind_id"
    t.index ["organization_department_id"], name: "index_core_projects_on_organization_department_id"
    t.index ["organization_id"], name: "index_core_projects_on_organization_id"
    t.index ["state"], name: "index_core_projects_on_state"
  end

  create_table "core_quota_kinds", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "measurement_ru"
    t.string "name_en"
    t.string "measurement_en"
  end

  create_table "core_request_fields", id: :serial, force: :cascade do |t|
    t.integer "request_id", null: false
    t.integer "value"
    t.integer "quota_kind_id"
    t.index ["request_id"], name: "index_core_request_fields_on_request_id"
  end

  create_table "core_requests", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "cluster_id", null: false
    t.string "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cpu_hours"
    t.integer "gpu_hours"
    t.integer "hdd_size"
    t.string "group_name"
    t.integer "creator_id"
    t.text "comment"
    t.text "reason"
    t.integer "changed_by_id"
    t.index ["changed_by_id"], name: "index_core_requests_on_changed_by_id"
    t.index ["cluster_id"], name: "index_core_requests_on_cluster_id"
    t.index ["creator_id"], name: "index_core_requests_on_creator_id"
    t.index ["project_id"], name: "index_core_requests_on_project_id"
  end

  create_table "core_research_areas", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "old_group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
    t.bigint "group_id"
    t.index ["group_id"], name: "index_core_research_areas_on_group_id"
  end

  create_table "core_research_areas_per_projects", id: :serial, force: :cascade do |t|
    t.integer "research_area_id"
    t.integer "project_id"
    t.index ["project_id"], name: "iproject_on_ira_per_projects"
    t.index ["research_area_id"], name: "ira_on_ira_per_projects"
  end

  create_table "core_sureties", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "state"
    t.string "comment"
    t.string "boss_full_name"
    t.string "boss_position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "document"
    t.integer "author_id"
    t.text "reason"
    t.integer "changed_by_id"
    t.index ["author_id"], name: "index_core_sureties_on_author_id"
    t.index ["changed_by_id"], name: "index_core_sureties_on_changed_by_id"
    t.index ["project_id"], name: "index_core_sureties_on_project_id"
  end

  create_table "core_surety_members", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "surety_id"
    t.integer "organization_id"
    t.integer "organization_department_id"
    t.index ["organization_id"], name: "index_core_surety_members_on_organization_id"
    t.index ["surety_id"], name: "index_core_surety_members_on_surety_id"
    t.index ["user_id"], name: "index_core_surety_members_on_user_id"
  end

  create_table "core_surety_scans", id: :serial, force: :cascade do |t|
    t.integer "surety_id"
    t.string "image"
    t.index ["surety_id"], name: "index_core_surety_scans_on_surety_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "face_menu_item_prefs", force: :cascade do |t|
    t.integer "position"
    t.string "menu"
    t.string "key"
    t.bigint "user_id"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_face_menu_item_prefs_on_key"
    t.index ["position"], name: "index_face_menu_item_prefs_on_position"
    t.index ["user_id"], name: "index_face_menu_item_prefs_on_user_id"
  end

  create_table "face_users_menus", force: :cascade do |t|
    t.string "menu"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "menu"], name: "index_face_users_menus_on_user_id_and_menu", unique: true
    t.index ["user_id"], name: "index_face_users_menus_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "weight"
    t.boolean "system"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hardware_items", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "name_en"
    t.text "description_ru"
    t.text "description_en"
    t.integer "lock_version"
    t.integer "kind_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hardware_items_states", id: :serial, force: :cascade do |t|
    t.integer "item_id"
    t.integer "state_id"
    t.text "reason_en"
    t.text "reason_ru"
    t.text "description_en"
    t.text "description_ru"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hardware_kinds", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "name_en"
    t.text "description_ru"
    t.text "description_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hardware_states", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "name_en"
    t.text "description_ru"
    t.text "description_en"
    t.integer "lock_version"
    t.integer "kind_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hardware_states_links", id: :serial, force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobstat_data_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "type", limit: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_jobstat_data_types_on_name"
  end

  create_table "jobstat_digest_float_data", id: :serial, force: :cascade do |t|
    t.string "name"
    t.bigint "job_id"
    t.float "value"
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_jobstat_digest_float_data_on_job_id"
  end

  create_table "jobstat_digest_string_data", id: :serial, force: :cascade do |t|
    t.string "name"
    t.bigint "job_id"
    t.string "value"
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_jobstat_digest_string_data_on_job_id"
  end

  create_table "jobstat_float_data", id: :serial, force: :cascade do |t|
    t.string "name"
    t.bigint "job_id"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_jobstat_float_data_on_job_id"
  end

  create_table "jobstat_job_mail_filters", id: :serial, force: :cascade do |t|
    t.string "condition"
    t.integer "user_id"
  end

  create_table "jobstat_jobs", id: :serial, force: :cascade do |t|
    t.string "cluster", limit: 32
    t.bigint "drms_job_id"
    t.bigint "drms_task_id"
    t.string "login", limit: 32
    t.string "partition", limit: 32
    t.datetime "submit_time"
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "timelimit"
    t.string "command", limit: 1024
    t.string "state", limit: 32
    t.bigint "num_cores"
    t.bigint "num_nodes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "nodelist"
    t.integer "initiator_id"
    t.index ["cluster", "drms_job_id", "drms_task_id"], name: "uniq_jobs", unique: true
    t.index ["end_time"], name: "index_jobstat_jobs_on_end_time"
    t.index ["login"], name: "index_jobstat_jobs_on_login"
    t.index ["partition"], name: "index_jobstat_jobs_on_partition"
    t.index ["start_time"], name: "index_jobstat_jobs_on_start_time"
    t.index ["state"], name: "index_jobstat_jobs_on_state"
    t.index ["submit_time"], name: "index_jobstat_jobs_on_submit_time"
  end

  create_table "jobstat_string_data", id: :serial, force: :cascade do |t|
    t.string "name"
    t.bigint "job_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_jobstat_string_data_on_job_id"
  end

  create_table "options", id: :serial, force: :cascade do |t|
    t.string "owner_type"
    t.integer "owner_id"
    t.string "name_ru"
    t.string "name_en"
    t.text "value_ru"
    t.text "value_en"
    t.integer "category_value_id"
    t.integer "options_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
  end

  create_table "options_categories", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pack_access_tickets", id: false, force: :cascade do |t|
    t.integer "access_id"
    t.integer "ticket_id"
    t.index ["access_id"], name: "index_pack_access_tickets_on_access_id"
    t.index ["ticket_id"], name: "index_pack_access_tickets_on_ticket_id"
  end

  create_table "pack_accesses", id: :serial, force: :cascade do |t|
    t.integer "version_id"
    t.integer "who_id"
    t.string "who_type"
    t.string "status"
    t.integer "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "end_lic"
    t.date "new_end_lic"
    t.integer "allowed_by_id"
    t.integer "lock_version", default: 0, null: false
    t.boolean "new_end_lic_forever", default: false
    t.string "to_type"
    t.bigint "to_id"
    t.index ["to_type", "to_id"], name: "index_pack_accesses_on_to_type_and_to_id"
    t.index ["version_id"], name: "index_pack_accesses_on_version_id"
    t.index ["who_type", "who_id"], name: "index_pack_accesses_on_who_type_and_who_id"
  end

  create_table "pack_category_values", id: :serial, force: :cascade do |t|
    t.integer "options_category_id"
    t.string "value_ru"
    t.string "value_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["options_category_id"], name: "index_pack_category_values_on_options_category_id"
  end

  create_table "pack_clustervers", id: :serial, force: :cascade do |t|
    t.integer "core_cluster_id"
    t.integer "version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "active"
    t.string "path"
    t.index ["core_cluster_id"], name: "index_pack_clustervers_on_core_cluster_id"
    t.index ["version_id"], name: "index_pack_clustervers_on_version_id"
  end

  create_table "pack_options_categories", id: :serial, force: :cascade do |t|
    t.string "category_ru"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_en"
  end

  create_table "pack_packages", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description_ru"
    t.boolean "deleted", default: false, null: false
    t.text "description_en"
    t.string "name_en"
    t.boolean "accesses_to_package", default: false
  end

  create_table "pack_version_options", id: :serial, force: :cascade do |t|
    t.integer "version_id"
    t.string "name_ru"
    t.text "value_ru"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_en"
    t.string "value_en"
    t.integer "category_value_id"
    t.integer "options_category_id"
    t.index ["version_id"], name: "index_pack_version_options_on_version_id"
  end

  create_table "pack_versions", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.text "description_ru"
    t.integer "package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cost"
    t.date "end_lic"
    t.string "state"
    t.integer "lock_col", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "service", default: false, null: false
    t.boolean "delete_on_expire", default: false, null: false
    t.integer "ticket_id"
    t.text "description_en"
    t.string "name_en"
    t.index ["package_id"], name: "index_pack_versions_on_package_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.string "action"
    t.string "subject_class"
    t.integer "group_id"
    t.boolean "available", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "subject_id"
    t.index ["group_id"], name: "index_permissions_on_group_id"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.text "about"
    t.boolean "receive_info_mails", default: true
    t.boolean "receive_special_mails", default: true
  end

  create_table "sessions_projects_in_sessions", id: :serial, force: :cascade do |t|
    t.integer "session_id"
    t.integer "project_id"
    t.index ["project_id"], name: "index_sessions_projects_in_sessions_on_project_id"
    t.index ["session_id", "project_id"], name: "i_on_project_and_sessions_ids", unique: true
    t.index ["session_id"], name: "index_sessions_projects_in_sessions_on_session_id"
  end

  create_table "sessions_report_materials", id: :serial, force: :cascade do |t|
    t.string "materials"
    t.string "materials_content_type"
    t.integer "materials_file_size"
    t.integer "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions_report_replies", id: :serial, force: :cascade do |t|
    t.integer "report_id"
    t.integer "user_id"
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["report_id"], name: "index_sessions_report_replies_on_report_id"
  end

  create_table "sessions_report_submit_denial_reasons", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "name_en"
  end

  create_table "sessions_reports", id: :serial, force: :cascade do |t|
    t.integer "session_id"
    t.integer "project_id"
    t.integer "author_id"
    t.integer "expert_id"
    t.string "state"
    t.string "materials"
    t.string "materials_file_name"
    t.string "materials_content_type"
    t.integer "materials_file_size"
    t.datetime "materials_updated_at"
    t.integer "illustration_points"
    t.integer "summary_points"
    t.integer "statement_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "submit_denial_reason_id"
    t.text "submit_denial_description"
    t.index ["author_id"], name: "index_sessions_reports_on_author_id"
    t.index ["expert_id"], name: "index_sessions_reports_on_expert_id"
    t.index ["project_id"], name: "index_sessions_reports_on_project_id"
    t.index ["session_id"], name: "index_sessions_reports_on_session_id"
  end

  create_table "sessions_sessions", id: :serial, force: :cascade do |t|
    t.string "state"
    t.text "description_ru"
    t.text "motivation_ru"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "receiving_to"
    t.text "description_en"
    t.text "motivation_en"
  end

  create_table "sessions_stats", id: :serial, force: :cascade do |t|
    t.integer "session_id"
    t.integer "survey_field_id"
    t.string "group_by", default: "count"
    t.integer "weight", default: 0
    t.integer "organization_id"
    t.text "cache"
    t.index ["session_id", "organization_id"], name: "index_sessions_stats_on_session_id_and_organization_id"
    t.index ["session_id", "survey_field_id"], name: "index_sessions_stats_on_session_id_and_survey_field_id"
    t.index ["session_id"], name: "index_sessions_stats_on_session_id"
  end

  create_table "sessions_survey_fields", id: :serial, force: :cascade do |t|
    t.integer "survey_id"
    t.string "kind"
    t.text "collection"
    t.integer "max_values", default: 1
    t.integer "weight", default: 0
    t.text "name_ru"
    t.boolean "required", default: false
    t.string "entity"
    t.boolean "strict_collection", default: false
    t.string "hint_ru"
    t.string "reference_type"
    t.string "regexp"
    t.string "hint_en"
    t.string "name_en"
    t.index ["survey_id"], name: "index_sessions_survey_fields_on_survey_id"
  end

  create_table "sessions_survey_kinds", id: :serial, force: :cascade do |t|
    t.string "name"
  end

  create_table "sessions_survey_values", id: :serial, force: :cascade do |t|
    t.text "value"
    t.integer "survey_field_id"
    t.integer "user_id"
    t.integer "user_survey_id"
    t.index ["survey_field_id", "user_survey_id"], name: "isurvey_field_and_user"
    t.index ["user_survey_id"], name: "index_sessions_survey_values_on_user_survey_id"
  end

  create_table "sessions_surveys", id: :serial, force: :cascade do |t|
    t.integer "session_id"
    t.integer "kind_id"
    t.string "name_ru"
    t.boolean "only_for_project_owners"
    t.string "name_en"
    t.index ["kind_id"], name: "index_sessions_surveys_on_kind_id"
    t.index ["session_id"], name: "index_sessions_surveys_on_session_id"
  end

  create_table "sessions_user_surveys", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "session_id"
    t.integer "survey_id"
    t.integer "project_id"
    t.string "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_sessions_user_surveys_on_project_id"
    t.index ["session_id", "survey_id"], name: "index_sessions_user_surveys_on_session_id_and_survey_id"
    t.index ["session_id"], name: "index_sessions_user_surveys_on_session_id"
    t.index ["user_id"], name: "index_sessions_user_surveys_on_user_id"
  end

  create_table "statistics_organization_stats", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics_project_stats", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics_session_stats", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics_user_stats", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_field_values", id: :serial, force: :cascade do |t|
    t.integer "field_id"
    t.integer "ticket_id"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ticket_id"], name: "index_support_field_values_on_ticket_id"
  end

  create_table "support_fields", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.string "hint_ru"
    t.boolean "required", default: false
    t.boolean "contains_source_code", default: false
    t.boolean "url", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
    t.string "hint_en"
  end

  create_table "support_replies", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.integer "ticket_id"
    t.text "message"
    t.string "attachment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["author_id"], name: "index_support_replies_on_author_id"
    t.index ["ticket_id"], name: "index_support_replies_on_ticket_id"
  end

  create_table "support_reply_templates", id: :serial, force: :cascade do |t|
    t.string "subject_ru"
    t.text "message_ru"
    t.string "subject_en"
    t.text "message_en"
  end

  create_table "support_tags", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
  end

  create_table "support_tickets", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "project_id"
    t.integer "cluster_id"
    t.integer "surety_id"
    t.integer "reporter_id"
    t.string "subject"
    t.text "message"
    t.string "state"
    t.string "url"
    t.string "attachment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "responsible_id"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["cluster_id"], name: "index_support_tickets_on_cluster_id"
    t.index ["project_id"], name: "index_support_tickets_on_project_id"
    t.index ["reporter_id"], name: "index_support_tickets_on_reporter_id"
    t.index ["responsible_id"], name: "index_support_tickets_on_responsible_id"
    t.index ["state"], name: "index_support_tickets_on_state"
    t.index ["topic_id"], name: "index_support_tickets_on_topic_id"
  end

  create_table "support_tickets_subscribers", id: :serial, force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "user_id"
    t.index ["ticket_id", "user_id"], name: "index_support_tickets_subscribers_on_ticket_id_and_user_id", unique: true
    t.index ["ticket_id"], name: "index_support_tickets_subscribers_on_ticket_id"
    t.index ["user_id"], name: "index_support_tickets_subscribers_on_user_id"
  end

  create_table "support_tickets_tags", id: :serial, force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "tag_id"
    t.index ["tag_id"], name: "index_support_tickets_tags_on_tag_id"
    t.index ["ticket_id"], name: "index_support_tickets_tags_on_ticket_id"
  end

  create_table "support_topics", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.integer "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
    t.text "template_en"
    t.text "template_ru"
    t.boolean "visible_on_create", default: true
  end

  create_table "support_topics_fields", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "field_id"
  end

  create_table "support_topics_tags", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "tag_id"
  end

  create_table "support_user_topics", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "topic_id"
    t.boolean "required", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "activation_state"
    t.string "activation_token"
    t.datetime "activation_token_expires_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string "access_state"
    t.datetime "deleted_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.string "language"
    t.index ["activation_token"], name: "index_users_on_activation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_login_at"], name: "index_users_on_last_login_at"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.string "session_id"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

  create_table "wiki_pages", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.text "content_ru"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
    t.text "content_en"
    t.index ["url"], name: "index_wiki_pages_on_url", unique: true
  end

  create_table "wikiplus_images", id: :serial, force: :cascade do |t|
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wikiplus_pages", id: :serial, force: :cascade do |t|
    t.string "name_ru"
    t.text "content_ru"
    t.string "url"
    t.boolean "show_all", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_en"
    t.text "content_en"
    t.decimal "sortid", precision: 5
    t.integer "mainpage_id"
    t.string "image"
    t.index ["mainpage_id"], name: "index_wikiplus_pages_on_mainpage_id"
    t.index ["url"], name: "index_wikiplus_pages_on_url", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "core_bot_links", "users"
end
