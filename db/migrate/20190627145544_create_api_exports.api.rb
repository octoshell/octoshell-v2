# This migration comes from api (originally 20190627143521)
class CreateApiExports < ActiveRecord::Migration[4.2]
  def change
    create_table :api_exports do |t|
      t.string :title
      t.text :request

      t.timestamps null: false
    end
  end
end
