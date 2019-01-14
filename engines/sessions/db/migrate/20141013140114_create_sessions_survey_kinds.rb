class CreateSessionsSurveyKinds < ActiveRecord::Migration
  def change
    create_table :sessions_survey_kinds do |t|
      t.string :name
    end
  end
end
