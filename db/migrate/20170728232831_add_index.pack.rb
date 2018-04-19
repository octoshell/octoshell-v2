# This migration comes from pack (originally 20170728232334)
class AddIndex < ActiveRecord::Migration
  def change
  	  add_index "pack_accesses", ["who_type", "who_id","version_id"], name: "who_type,who_id,vers_id index", using: :btree

  end
end
