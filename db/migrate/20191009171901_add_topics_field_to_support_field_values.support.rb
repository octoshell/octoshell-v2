# This migration comes from support (originally 20191009164238)
class AddTopicsFieldToSupportFieldValues < ActiveRecord::Migration[5.2]
  def change
    add_reference :support_field_values, :topics_field, foreign_key: {to_table: :support_topics_fields}
  end
end
