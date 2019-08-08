# This migration comes from sessions (originally 20141013140114)
class CreateSessionsSurveyKinds < ActiveRecord::Migration[4.2]
  def change
    create_table :sessions_survey_kinds do |t|
      t.string :name
    end
  end
end
