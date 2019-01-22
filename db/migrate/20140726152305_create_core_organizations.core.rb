# This migration comes from core (originally 20140726135747)
class CreateCoreOrganizations < ActiveRecord::Migration
  def change
    create_table :core_organizations do |t|
      t.string :name
      t.string :abbreviation
      t.integer :kind_id
      t.integer :country_id
      t.integer :city_id

      t.timestamps

      t.index :kind_id
      t.index :country_id
      t.index :city_id
    end
  end
end
