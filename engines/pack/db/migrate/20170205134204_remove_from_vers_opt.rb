class RemoveFromVersOpt < ActiveRecord::Migration
  def change
  	 remove_column :pack_version_options,     "admin_answer"
    remove_column :pack_version_options,      "end_date"
    remove_column :pack_version_options,     "request_text"
  end
end
