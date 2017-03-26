# This migration comes from pack (originally 20170314131932)
class Deleteprop < ActiveRecord::Migration
  def change
  	drop_table :pack_props
  end
end
