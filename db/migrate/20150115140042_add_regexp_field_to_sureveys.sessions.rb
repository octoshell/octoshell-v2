# This migration comes from sessions (originally 20150115134405)
class AddRegexpFieldToSureveys < ActiveRecord::Migration
  def change
    add_column :sessions_survey_fields, :regexp, :string
  end
end
