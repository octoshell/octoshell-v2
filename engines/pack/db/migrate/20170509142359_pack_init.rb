class PackInit < ActiveRecord::Migration
  def change
	  create_table "pack_access_tickets", id: false, force: :cascade do |t|
	    t.integer "access_id"
	    t.integer "ticket_id"
	  end

	  add_index "pack_access_tickets", ["access_id"], name: "index_pack_access_tickets_on_access_id", using: :btree
	  add_index "pack_access_tickets", ["ticket_id"], name: "index_pack_access_tickets_on_ticket_id", using: :btree

	  create_table "pack_accesses", force: :cascade do |t|
	    t.integer  "version_id"
	    t.integer  "who_id"
	    t.string   "who_type"
	    t.string   "status"
	    t.integer  "created_by_id"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.date     "end_lic"
	    t.date     "new_end_lic"
	    t.integer  "allowed_by_id"
	    t.integer  "lock_version",  default: 0, null: false
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

	  create_table "pack_options_categories", force: :cascade do |t|
	    t.string   "category"
	    t.datetime "created_at", null: false
	    t.datetime "updated_at", null: false
	  end

	  create_table "pack_packages", force: :cascade do |t|
	    t.string   "name"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.text     "description"
	    t.boolean  "deleted",     default: false,null: false
	  end

	  create_table "pack_version_options", force: :cascade do |t|
	    t.integer  "version_id"
	    t.string   "name"
	    t.text     "value"
	    t.datetime "created_at", null: false
	    t.datetime "updated_at", null: false
	  end

	  add_index "pack_version_options", ["version_id"], name: "index_pack_version_options_on_version_id", using: :btree

	  create_table "pack_versions", force: :cascade do |t|
	    t.string   "name"
	    t.text     "description"
	    t.integer  "package_id"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.integer  "cost"
	    t.string   "folder"
	    t.date     "end_lic"
	    t.string   "state"
	    t.integer  "lock_col",         default: 0,     null: false
	    t.boolean  "deleted",          default: false, null: false
	    t.boolean  "service",          default: false, null: false
	    t.boolean  "delete_on_expire", default: false, null: false
	  end

	  add_index "pack_versions", ["package_id"], name: "index_pack_versions_on_package_id", using: :btree


	end
end
