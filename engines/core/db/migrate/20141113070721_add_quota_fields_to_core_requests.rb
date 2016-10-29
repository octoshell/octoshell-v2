class AddQuotaFieldsToCoreRequests < ActiveRecord::Migration
  def change
    add_column :core_requests, :cpu_hours, :integer
    add_column :core_requests, :gpu_hours, :integer
    add_column :core_requests, :hdd_size, :integer
    add_column :core_requests, :group_name, :string
  end
end
