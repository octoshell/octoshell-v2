# This migration comes from core (originally 20180101132806)
class AddCheckedToCoreCountries < ActiveRecord::Migration
  def change
    add_column :core_countries, :checked, :boolean, default: false
  end
end
