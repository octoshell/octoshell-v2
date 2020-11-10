# This migration comes from support (originally 20191013131955)
class NewAttributesToSupportFields < ActiveRecord::Migration[5.2]
  def change
    add_column :support_fields, :kind, :integer, default: 0
  end
end
