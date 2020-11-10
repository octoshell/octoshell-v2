class AddRequiredToSupportTopicsFields < ActiveRecord::Migration[5.2]
  def change
    add_column :support_topics_fields, :required, :boolean, default: false
  end
end
