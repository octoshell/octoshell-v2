class IncreaseSurveyFieldNameLength < ActiveRecord::Migration
  def change
    change_column :sessions_survey_fields, :name, :text
  end
end
