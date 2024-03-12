class AddSearchToSupportFields < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :support_fields, :search
      add_column :support_fields, :search, :boolean, default: false
    end
  end
end
