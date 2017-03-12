create_table "pack_accesses", force: :cascade do |t|
    t.integer  "version_id"
    t.integer  "who_id" # id для полиморфной связи Доступ-Проект или Доступ-Пользователь
    t.string   "who_type" #тип связи

    t.string   "status" #статус доступа( заявка,разрешен,запрещен или истек)
    t.integer  "user_id" # кто запросил или выдал доступ
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date   "begin_lic" #когда предоставлен доступ
    t.date   "new_end_lic" # дата заявки на продление доступа
    t.date     "end_lic" # дата окончания доступа
    t.integer  "support_ticket_id"
  end

  add_index "pack_accesses", ["version_id"], name: "index_pack_accesses_on_version_id", using: :btree
  add_index "pack_accesses", ["who_type", "who_id"], name: "index_pack_accesses_on_who_type_and_who_id", using: :btree

  create_table "pack_clustervers", force: :cascade do |t|
    t.integer  "core_cluster_id" #Связь Кластер-Версия определяет активность и существование версиии на кластере
    t.integer  "version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    
  end

  add_index "pack_clustervers", ["core_cluster_id"], name: "index_pack_clustervers_on_core_cluster_id", using: :btree
  add_index "pack_clustervers", ["version_id"], name: "index_pack_clustervers_on_version_id", using: :btree

  create_table "pack_options_categories", force: :cascade do |t|
    t.string   "category" # С помощью select2-ajax можно будет название опции заполнить этим значением
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pack_packages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "deleted",      default: false 
    t.integer  "lock_version", default: 0,     null: false
  end

  create_table "pack_props", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "proj_or_user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "def_date"
  end

  add_index "pack_props", ["user_id"], name: "index_pack_props_on_user_id", using: :btree

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
  end

  add_index "pack_versions", ["package_id"], name: "index_pack_versions_on_package_id", using: :btree
