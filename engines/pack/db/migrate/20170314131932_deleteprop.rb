class Deleteprop < ActiveRecord::Migration
  def change
  	drop_table :pack_props
  end
end
