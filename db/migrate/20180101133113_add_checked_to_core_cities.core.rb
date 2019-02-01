# This migration comes from core (originally 20180101132620)
class AddCheckedToCoreCities < ActiveRecord::Migration
  def change
    add_column :core_cities, :checked, :boolean, default: false
  end
end
