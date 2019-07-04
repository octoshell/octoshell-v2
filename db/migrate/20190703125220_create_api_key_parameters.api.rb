# This migration comes from api (originally 20190703123251)
class CreateApiKeyParameters < ActiveRecord::Migration
  def change
    create_table :api_key_parameters do |t|
      t.string :name
      t.string :default

      t.timestamps null: false
    end
  end
end
