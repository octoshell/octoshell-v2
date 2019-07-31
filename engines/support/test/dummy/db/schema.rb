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

ActiveRecord::Schema.define(version: 20180907145616) do

  create_table "support_field_values", force: :cascade do |t|
    t.integer  "field_id"
    t.integer  "ticket_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "support_field_values", ["ticket_id"], name: "index_support_field_values_on_ticket_id"

  create_table "support_fields", force: :cascade do |t|
    t.string   "name"
    t.string   "hint"
    t.boolean  "required",             default: false
    t.boolean  "contains_source_code", default: false
    t.boolean  "url",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_replies", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "ticket_id"
    t.text     "message"
    t.string   "attachment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "support_replies", ["author_id"], name: "index_support_replies_on_author_id"
  add_index "support_replies", ["ticket_id"], name: "index_support_replies_on_ticket_id"

  create_table "support_reply_templates", force: :cascade do |t|
    t.string "subject"
    t.text   "message"
  end

  create_table "support_tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.integer  "topic_id"
    t.integer  "project_id"
    t.integer  "cluster_id"
    t.integer  "surety_id"
    t.integer  "reporter_id"
    t.string   "subject"
    t.text     "message"
    t.string   "state"
    t.string   "url"
    t.string   "attachment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "responsible_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "support_tickets", ["cluster_id"], name: "index_support_tickets_on_cluster_id"
  add_index "support_tickets", ["project_id"], name: "index_support_tickets_on_project_id"
  add_index "support_tickets", ["reporter_id"], name: "index_support_tickets_on_reporter_id"
  add_index "support_tickets", ["responsible_id"], name: "index_support_tickets_on_responsible_id"
  add_index "support_tickets", ["state"], name: "index_support_tickets_on_state"
  add_index "support_tickets", ["topic_id"], name: "index_support_tickets_on_topic_id"

  create_table "support_tickets_subscribers", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "user_id"
  end

  add_index "support_tickets_subscribers", ["ticket_id", "user_id"], name: "index_support_tickets_subscribers_on_ticket_id_and_user_id", unique: true
  add_index "support_tickets_subscribers", ["ticket_id"], name: "index_support_tickets_subscribers_on_ticket_id"
  add_index "support_tickets_subscribers", ["user_id"], name: "index_support_tickets_subscribers_on_user_id"

  create_table "support_tickets_tags", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "tag_id"
  end

  add_index "support_tickets_tags", ["tag_id"], name: "index_support_tickets_tags_on_tag_id"
  add_index "support_tickets_tags", ["ticket_id"], name: "index_support_tickets_tags_on_ticket_id"

  create_table "support_topics", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "template_en"
    t.text     "template_ru"
    t.boolean  "visible_on_create", default: true
  end

  create_table "support_topics_fields", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "field_id"
  end

  create_table "support_topics_tags", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "tag_id"
  end

  create_table "support_user_topics", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.boolean  "required",   default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
