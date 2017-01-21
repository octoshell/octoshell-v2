class AddStatusToVersion < ActiveRecord::Migration
  def change
  	drop_table :pack_projectsvers
  	drop_table :pack_uservers
  end
end
