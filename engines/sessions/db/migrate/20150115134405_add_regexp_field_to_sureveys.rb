class AddRegexpFieldToSureveys < ActiveRecord::Migration
  def change
    add_column :sessions_survey_fields, :regexp, :string
  end
end
