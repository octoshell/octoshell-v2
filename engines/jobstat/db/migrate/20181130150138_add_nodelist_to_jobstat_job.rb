class AddNodelistToJobstatJob < ActiveRecord::Migration
  def change
    add_column :jobstat_jobs, :nodelist, :text
  end
end
