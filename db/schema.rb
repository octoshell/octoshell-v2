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

ActiveRecord::Schema.define(version: 20170114194743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abilities", force: :cascade do |t|
    t.string   "action",     limit: 255
    t.string   "subject",    limit: 255
    t.integer  "group_id"
    t.boolean  "available",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "abilities", ["group_id"], name: "index_abilities_on_group_id", using: :btree

  create_table "announcement_recipients", force: :cascade do |t|
    t.integer "user_id"
    t.integer "announcement_id"
  end

  add_index "announcement_recipients", ["announcement_id"], name: "index_announcement_recipients_on_announcement_id", using: :btree
  add_index "announcement_recipients", ["user_id"], name: "index_announcement_recipients_on_user_id", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "reply_to",   limit: 255
    t.text     "body"
    t.string   "attachment", limit: 255
    t.boolean  "is_special"
    t.string   "state",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_access_fields", force: :cascade do |t|
    t.integer "access_id"
    t.integer "quota"
    t.integer "used",          default: 0
    t.integer "quota_kind_id"
  end

  add_index "core_access_fields", ["access_id"], name: "index_core_access_fields_on_access_id", using: :btree

  create_table "core_accesses", force: :cascade do |t|
    t.integer  "project_id",                     null: false
    t.integer  "cluster_id",                     null: false
    t.string   "state",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "project_group_name", limit: 255
  end

  add_index "core_accesses", ["cluster_id"], name: "index_core_accesses_on_cluster_id", using: :btree
  add_index "core_accesses", ["project_id", "cluster_id"], name: "index_core_accesses_on_project_id_and_cluster_id", unique: true, using: :btree
  add_index "core_accesses", ["project_id"], name: "index_core_accesses_on_project_id", using: :btree

  create_table "core_cities", force: :cascade do |t|
    t.integer "country_id"
    t.string  "title_ru",   limit: 255
    t.string  "title_en",   limit: 255
  end

  add_index "core_cities", ["country_id"], name: "index_core_cities_on_country_id", using: :btree
  add_index "core_cities", ["title_ru"], name: "index_core_cities_on_title_ru", using: :btree

  create_table "core_cluster_logs", force: :cascade do |t|
    t.integer  "cluster_id", null: false
    t.text     "message",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "core_cluster_logs", ["cluster_id"], name: "index_core_cluster_logs_on_cluster_id", using: :btree
  add_index "core_cluster_logs", ["project_id"], name: "index_core_cluster_logs_on_project_id", using: :btree

  create_table "core_cluster_quotas", force: :cascade do |t|
    t.integer "cluster_id",    null: false
    t.integer "value"
    t.integer "quota_kind_id"
  end

  add_index "core_cluster_quotas", ["cluster_id"], name: "index_core_cluster_quotas_on_cluster_id", using: :btree

  create_table "core_clusters", force: :cascade do |t|
    t.string   "name",               limit: 255,                null: false
    t.string   "host",               limit: 255,                null: false
    t.text     "description"
    t.text     "public_key"
    t.text     "private_key"
    t.string   "admin_login",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available_for_work",             default: true
  end

  add_index "core_clusters", ["private_key"], name: "index_core_clusters_on_private_key", unique: true, using: :btree
  add_index "core_clusters", ["public_key"], name: "index_core_clusters_on_public_key", unique: true, using: :btree

  create_table "core_countries", force: :cascade do |t|
    t.string "title_ru", limit: 255
    t.string "title_en", limit: 255
  end

  create_table "core_credentials", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "state",      limit: 255
    t.string   "name",       limit: 255, null: false
    t.text     "public_key",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_credentials", ["user_id"], name: "index_core_credentials_on_user_id", using: :btree

  create_table "core_critical_technologies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_critical_technologies_per_projects", force: :cascade do |t|
    t.integer "critical_technology_id"
    t.integer "project_id"
  end

  add_index "core_critical_technologies_per_projects", ["critical_technology_id"], name: "icrittechs_on_critical_technologies_per_projects", using: :btree
  add_index "core_critical_technologies_per_projects", ["project_id"], name: "iprojects_on_critical_technologies_per_projects", using: :btree

  create_table "core_direction_of_sciences", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_direction_of_sciences_per_projects", force: :cascade do |t|
    t.integer "direction_of_science_id"
    t.integer "project_id"
  end

  add_index "core_direction_of_sciences_per_projects", ["direction_of_science_id"], name: "idos_on_dos_per_projects", using: :btree
  add_index "core_direction_of_sciences_per_projects", ["project_id"], name: "iproject_on_dos_per_projects", using: :btree

  create_table "core_employment_position_names", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "autocomplete"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_employment_positions", force: :cascade do |t|
    t.integer  "employment_id"
    t.string   "name",          limit: 255
    t.string   "value",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_employment_positions", ["employment_id"], name: "index_core_employment_positions_on_employment_id", using: :btree

  create_table "core_employments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "primary"
    t.string   "state",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_department_id"
  end

  add_index "core_employments", ["organization_department_id"], name: "index_core_employments_on_organization_department_id", using: :btree

  create_table "core_members", force: :cascade do |t|
    t.integer  "user_id",                                                null: false
    t.integer  "project_id",                                             null: false
    t.boolean  "owner",                                  default: false
    t.string   "login",                      limit: 255
    t.string   "project_access_state",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "organization_department_id"
  end

  add_index "core_members", ["organization_id"], name: "index_core_members_on_organization_id", using: :btree
  add_index "core_members", ["owner", "user_id", "project_id"], name: "index_core_members_on_owner_and_user_id_and_project_id", using: :btree
  add_index "core_members", ["project_access_state"], name: "index_core_members_on_project_access_state", using: :btree
  add_index "core_members", ["project_id"], name: "index_core_members_on_project_id", using: :btree
  add_index "core_members", ["user_id", "owner"], name: "index_core_members_on_user_id_and_owner", using: :btree
  add_index "core_members", ["user_id", "project_id"], name: "index_core_members_on_user_id_and_project_id", unique: true, using: :btree
  add_index "core_members", ["user_id"], name: "index_core_members_on_user_id", using: :btree

  create_table "core_organization_departments", force: :cascade do |t|
    t.integer "organization_id"
    t.string  "name",            limit: 255
  end

  add_index "core_organization_departments", ["organization_id"], name: "index_core_organization_departments_on_organization_id", using: :btree

  create_table "core_organization_kinds", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.boolean  "departments_required",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_organizations", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "abbreviation", limit: 255
    t.integer  "kind_id"
    t.integer  "country_id"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_organizations", ["city_id"], name: "index_core_organizations_on_city_id", using: :btree
  add_index "core_organizations", ["country_id"], name: "index_core_organizations_on_country_id", using: :btree
  add_index "core_organizations", ["kind_id"], name: "index_core_organizations_on_kind_id", using: :btree

  create_table "core_project_cards", force: :cascade do |t|
    t.integer  "project_id"
    t.text     "name"
    t.text     "en_name"
    t.text     "driver"
    t.text     "en_driver"
    t.text     "strategy"
    t.text     "en_strategy"
    t.text     "objective"
    t.text     "en_objective"
    t.text     "impact"
    t.text     "en_impact"
    t.text     "usage"
    t.text     "en_usage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_project_cards", ["project_id"], name: "index_core_project_cards_on_project_id", using: :btree

  create_table "core_project_invitations", force: :cascade do |t|
    t.integer  "project_id",             null: false
    t.string   "user_fio",   limit: 255, null: false
    t.string   "user_email", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_project_invitations", ["project_id"], name: "index_core_project_invitations_on_project_id", using: :btree

  create_table "core_project_kinds", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "core_projects", force: :cascade do |t|
    t.string   "title",                      limit: 255, null: false
    t.string   "state",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "organization_department_id"
    t.integer  "kind_id"
    t.datetime "first_activation_at"
    t.datetime "finished_at"
    t.datetime "estimated_finish_date"
  end

  add_index "core_projects", ["kind_id"], name: "index_core_projects_on_kind_id", using: :btree
  add_index "core_projects", ["organization_department_id"], name: "index_core_projects_on_organization_department_id", using: :btree
  add_index "core_projects", ["organization_id"], name: "index_core_projects_on_organization_id", using: :btree
  add_index "core_projects", ["state"], name: "index_core_projects_on_state", using: :btree

  create_table "core_quota_kinds", force: :cascade do |t|
    t.string "name",        limit: 255
    t.string "measurement", limit: 255
  end

  create_table "core_request_fields", force: :cascade do |t|
    t.integer "request_id",    null: false
    t.integer "value"
    t.integer "quota_kind_id"
  end

  add_index "core_request_fields", ["request_id"], name: "index_core_request_fields_on_request_id", using: :btree

  create_table "core_requests", force: :cascade do |t|
    t.integer  "project_id",             null: false
    t.integer  "cluster_id",             null: false
    t.string   "state",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cpu_hours"
    t.integer  "gpu_hours"
    t.integer  "hdd_size"
    t.string   "group_name", limit: 255
    t.integer  "creator_id"
    t.text     "comment"
  end

  add_index "core_requests", ["cluster_id"], name: "index_core_requests_on_cluster_id", using: :btree
  add_index "core_requests", ["creator_id"], name: "index_core_requests_on_creator_id", using: :btree
  add_index "core_requests", ["project_id"], name: "index_core_requests_on_project_id", using: :btree

  create_table "core_research_areas", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "group",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "core_research_areas_per_projects", force: :cascade do |t|
    t.integer "research_area_id"
    t.integer "project_id"
  end

  add_index "core_research_areas_per_projects", ["project_id"], name: "iproject_on_ira_per_projects", using: :btree
  add_index "core_research_areas_per_projects", ["research_area_id"], name: "ira_on_ira_per_projects", using: :btree

  create_table "core_sureties", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "state",          limit: 255
    t.string   "comment",        limit: 255
    t.string   "boss_full_name", limit: 255
    t.string   "boss_position",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document",       limit: 255
    t.integer  "author_id"
  end

  add_index "core_sureties", ["author_id"], name: "index_core_sureties_on_author_id", using: :btree
  add_index "core_sureties", ["project_id"], name: "index_core_sureties_on_project_id", using: :btree

  create_table "core_surety_members", force: :cascade do |t|
    t.integer "user_id"
    t.integer "surety_id"
    t.integer "organization_id"
    t.integer "organization_department_id"
  end

  add_index "core_surety_members", ["organization_id"], name: "index_core_surety_members_on_organization_id", using: :btree
  add_index "core_surety_members", ["surety_id"], name: "index_core_surety_members_on_surety_id", using: :btree
  add_index "core_surety_members", ["user_id"], name: "index_core_surety_members_on_user_id", using: :btree

  create_table "core_surety_scans", force: :cascade do |t|
    t.integer "surety_id"
    t.string  "image",     limit: 255
  end

  add_index "core_surety_scans", ["surety_id"], name: "index_core_surety_scans_on_surety_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "weight"
    t.boolean  "system"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pack_accesses", force: :cascade do |t|
    t.integer  "version_id"
    t.integer  "who_id"
    t.string   "who_type"
    t.integer  "status"
    t.integer  "user_id"
    t.text     "admin_answer"
    t.text     "end_date"
    t.text     "request_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pack_accesses", ["version_id"], name: "index_pack_accesses_on_version_id", using: :btree
  add_index "pack_accesses", ["who_type", "who_id"], name: "index_pack_accesses_on_who_type_and_who_id", using: :btree

  create_table "pack_clustervers", force: :cascade do |t|
    t.integer  "core_cluster_id"
    t.integer  "version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
  end

  add_index "pack_clustervers", ["core_cluster_id"], name: "index_pack_clustervers_on_core_cluster_id", using: :btree
  add_index "pack_clustervers", ["version_id"], name: "index_pack_clustervers_on_version_id", using: :btree

  create_table "pack_packages", force: :cascade do |t|
    t.string   "name"
    t.string   "folder"
    t.integer  "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "deleted",     default: false
  end

  create_table "pack_props", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "proj_or_user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pack_props", ["user_id"], name: "index_pack_props_on_user_id", using: :btree

  create_table "pack_versions", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "r_up"
    t.text     "r_down"
  end

  add_index "pack_versions", ["package_id"], name: "index_pack_versions_on_package_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id",                                          null: false
    t.string  "first_name",            limit: 255
    t.string  "last_name",             limit: 255
    t.string  "middle_name",           limit: 255
    t.text    "about"
    t.boolean "receive_info_mails",                default: true
    t.boolean "receive_special_mails",             default: true
  end

  create_table "sessions_projects_in_sessions", force: :cascade do |t|
    t.integer "session_id"
    t.integer "project_id"
  end

  add_index "sessions_projects_in_sessions", ["project_id"], name: "index_sessions_projects_in_sessions_on_project_id", using: :btree
  add_index "sessions_projects_in_sessions", ["session_id", "project_id"], name: "i_on_project_and_sessions_ids", unique: true, using: :btree
  add_index "sessions_projects_in_sessions", ["session_id"], name: "index_sessions_projects_in_sessions_on_session_id", using: :btree

  create_table "sessions_report_replies", force: :cascade do |t|
    t.integer  "report_id"
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions_report_replies", ["report_id"], name: "index_sessions_report_replies_on_report_id", using: :btree

  create_table "sessions_report_submit_denial_reasons", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "sessions_reports", force: :cascade do |t|
    t.integer  "session_id"
    t.integer  "project_id"
    t.integer  "author_id"
    t.integer  "expert_id"
    t.string   "state",                     limit: 255
    t.string   "materials",                 limit: 255
    t.string   "materials_file_name",       limit: 255
    t.string   "materials_content_type",    limit: 255
    t.integer  "materials_file_size"
    t.datetime "materials_updated_at"
    t.integer  "illustration_points"
    t.integer  "summary_points"
    t.integer  "statement_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "submit_denial_reason_id"
    t.text     "submit_denial_description"
  end

  add_index "sessions_reports", ["author_id"], name: "index_sessions_reports_on_author_id", using: :btree
  add_index "sessions_reports", ["expert_id"], name: "index_sessions_reports_on_expert_id", using: :btree
  add_index "sessions_reports", ["project_id"], name: "index_sessions_reports_on_project_id", using: :btree
  add_index "sessions_reports", ["session_id"], name: "index_sessions_reports_on_session_id", using: :btree

  create_table "sessions_sessions", force: :cascade do |t|
    t.string   "state",        limit: 255
    t.text     "description"
    t.text     "motivation"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "receiving_to"
  end

  create_table "sessions_stats", force: :cascade do |t|
    t.integer "session_id"
    t.integer "survey_field_id"
    t.string  "group_by",        limit: 255, default: "count"
    t.integer "weight",                      default: 0
    t.integer "organization_id"
    t.text    "cache"
  end

  add_index "sessions_stats", ["session_id", "organization_id"], name: "index_sessions_stats_on_session_id_and_organization_id", using: :btree
  add_index "sessions_stats", ["session_id", "survey_field_id"], name: "index_sessions_stats_on_session_id_and_survey_field_id", using: :btree
  add_index "sessions_stats", ["session_id"], name: "index_sessions_stats_on_session_id", using: :btree

  create_table "sessions_survey_fields", force: :cascade do |t|
    t.integer "survey_id"
    t.string  "kind",              limit: 255
    t.text    "collection"
    t.integer "max_values",                    default: 1
    t.integer "weight",                        default: 0
    t.text    "name"
    t.boolean "required",                      default: false
    t.string  "entity",            limit: 255
    t.boolean "strict_collection",             default: false
    t.string  "hint",              limit: 255
    t.string  "reference_type",    limit: 255
    t.string  "regexp",            limit: 255
  end

  add_index "sessions_survey_fields", ["survey_id"], name: "index_sessions_survey_fields_on_survey_id", using: :btree

  create_table "sessions_survey_kinds", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "sessions_survey_values", force: :cascade do |t|
    t.text    "value"
    t.integer "survey_field_id"
    t.integer "user_id"
    t.integer "user_survey_id"
  end

  add_index "sessions_survey_values", ["survey_field_id", "user_survey_id"], name: "isurvey_field_and_user", using: :btree
  add_index "sessions_survey_values", ["user_survey_id"], name: "index_sessions_survey_values_on_user_survey_id", using: :btree

  create_table "sessions_surveys", force: :cascade do |t|
    t.integer "session_id"
    t.integer "kind_id"
    t.string  "name",                    limit: 255
    t.boolean "only_for_project_owners"
  end

  add_index "sessions_surveys", ["kind_id"], name: "index_sessions_surveys_on_kind_id", using: :btree
  add_index "sessions_surveys", ["session_id"], name: "index_sessions_surveys_on_session_id", using: :btree

  create_table "sessions_user_surveys", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "session_id"
    t.integer  "survey_id"
    t.integer  "project_id"
    t.string   "state",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions_user_surveys", ["project_id"], name: "index_sessions_user_surveys_on_project_id", using: :btree
  add_index "sessions_user_surveys", ["session_id", "survey_id"], name: "index_sessions_user_surveys_on_session_id_and_survey_id", using: :btree
  add_index "sessions_user_surveys", ["session_id"], name: "index_sessions_user_surveys_on_session_id", using: :btree
  add_index "sessions_user_surveys", ["user_id"], name: "index_sessions_user_surveys_on_user_id", using: :btree

  create_table "statistics_organization_stats", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics_project_stats", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics_session_stats", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics_user_stats", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_field_values", force: :cascade do |t|
    t.integer  "field_id"
    t.integer  "ticket_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "support_field_values", ["ticket_id"], name: "index_support_field_values_on_ticket_id", using: :btree

  create_table "support_fields", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "hint",                 limit: 255
    t.boolean  "required",                         default: false
    t.boolean  "contains_source_code",             default: false
    t.boolean  "url",                              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_replies", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "ticket_id"
    t.text     "message"
    t.string   "attachment",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "support_replies", ["author_id"], name: "index_support_replies_on_author_id", using: :btree
  add_index "support_replies", ["ticket_id"], name: "index_support_replies_on_ticket_id", using: :btree

  create_table "support_reply_templates", force: :cascade do |t|
    t.string "subject", limit: 255
    t.text   "message"
  end

  create_table "support_tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.integer  "topic_id"
    t.integer  "project_id"
    t.integer  "cluster_id"
    t.integer  "surety_id"
    t.integer  "reporter_id"
    t.string   "subject",                 limit: 255
    t.text     "message"
    t.string   "state",                   limit: 255
    t.string   "url",                     limit: 255
    t.string   "attachment",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "responsible_id"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "support_tickets", ["cluster_id"], name: "index_support_tickets_on_cluster_id", using: :btree
  add_index "support_tickets", ["project_id"], name: "index_support_tickets_on_project_id", using: :btree
  add_index "support_tickets", ["reporter_id"], name: "index_support_tickets_on_reporter_id", using: :btree
  add_index "support_tickets", ["responsible_id"], name: "index_support_tickets_on_responsible_id", using: :btree
  add_index "support_tickets", ["state"], name: "index_support_tickets_on_state", using: :btree
  add_index "support_tickets", ["topic_id"], name: "index_support_tickets_on_topic_id", using: :btree

  create_table "support_tickets_subscribers", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "user_id"
  end

  add_index "support_tickets_subscribers", ["ticket_id", "user_id"], name: "index_support_tickets_subscribers_on_ticket_id_and_user_id", unique: true, using: :btree
  add_index "support_tickets_subscribers", ["ticket_id"], name: "index_support_tickets_subscribers_on_ticket_id", using: :btree
  add_index "support_tickets_subscribers", ["user_id"], name: "index_support_tickets_subscribers_on_user_id", using: :btree

  create_table "support_tickets_tags", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "tag_id"
  end

  add_index "support_tickets_tags", ["tag_id"], name: "index_support_tickets_tags_on_tag_id", using: :btree
  add_index "support_tickets_tags", ["ticket_id"], name: "index_support_tickets_tags_on_ticket_id", using: :btree

  create_table "support_topics", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_topics_fields", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "field_id"
  end

  create_table "support_topics_tags", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "tag_id"
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  add_index "user_groups", ["group_id"], name: "index_user_groups_on_group_id", using: :btree
  add_index "user_groups", ["user_id"], name: "index_user_groups_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                           limit: 255, null: false
    t.string   "crypted_password",                limit: 255
    t.string   "salt",                            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_state",                limit: 255
    t.string   "activation_token",                limit: 255
    t.datetime "activation_token_expires_at"
    t.string   "remember_me_token",               limit: 255
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token",            limit: 255
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "access_state",                    limit: 255
    t.datetime "deleted_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address",      limit: 255
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["last_login_at"], name: "index_users_on_last_login_at", using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

  create_table "wiki_packages", force: :cascade do |t|
    t.string   "pname"
    t.string   "pfolder"
    t.text     "pcontent"
    t.datetime "pexp_date"
    t.string   "purl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wiki_packages", ["purl"], name: "index_wiki_packages_on_purl", unique: true, using: :btree

  create_table "wiki_pages", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "content"
    t.string   "url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wiki_pages", ["url"], name: "index_wiki_pages_on_url", unique: true, using: :btree

end
