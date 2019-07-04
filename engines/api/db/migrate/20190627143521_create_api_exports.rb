class CreateApiExports < ActiveRecord::Migration
  def change
    create_table :api_exports do |t|
      t.string :title
      t.text :request

      t.timestamps null: false
    end
  end
end
