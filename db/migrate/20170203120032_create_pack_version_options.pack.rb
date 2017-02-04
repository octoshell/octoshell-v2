# This migration comes from pack (originally 20170201073259)
class CreatePackVersionOptions < ActiveRecord::Migration
  def change
    create_table :pack_version_options do |t|
      t.belongs_to :version,index: true
      t.string :name
      t.string :value
      t.text     "admin_answer"
    t.text     "end_date"
    t.text     "request_text"
      t.timestamps null: false
    end
  end
end
