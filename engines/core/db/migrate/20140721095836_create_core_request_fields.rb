class CreateCoreRequestFields < ActiveRecord::Migration
  def change
    create_table :core_request_fields do |t|
      t.integer "request_id", null: false
      t.string  "name"
      t.integer "value"

      t.index :request_id
    end
  end
end
