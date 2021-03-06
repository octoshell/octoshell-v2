# This migration comes from support (originally 20140827144322)
class CreateSupportFields < ActiveRecord::Migration[4.2]
  def change
    create_table :support_fields do |t|
      t.string :name
      t.string :hint
      t.boolean :required, default: false
      t.boolean :contains_source_code, default: false
      t.boolean :url, default: false

      t.timestamps
    end
  end
end
