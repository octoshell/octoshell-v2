# This migration comes from core (originally 20180101132620)
class AddCheckedToCoreCities < ActiveRecord::Migration[4.2]
  def change
    add_column :core_cities, :checked, :boolean, default: false
  end
end
