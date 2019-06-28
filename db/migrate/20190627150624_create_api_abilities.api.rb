# This migration comes from api (originally 20190627150003)
class CreateApiAbilities < ActiveRecord::Migration
  def change
    create_table :api_abilities do |t|
      t.string :key

      t.timestamps null: false
    end
  end
end
