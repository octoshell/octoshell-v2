# This migration comes from pack (originally 20170112112144)
class AddStatusToVersion < ActiveRecord::Migration
  def change
  	drop_table :pack_projectsvers
  	drop_table :pack_uservers
  end
end
