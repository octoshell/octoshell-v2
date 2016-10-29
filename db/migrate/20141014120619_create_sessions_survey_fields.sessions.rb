# This migration comes from sessions (originally 20141013140209)
class CreateSessionsSurveyFields < ActiveRecord::Migration
  def change
    create_table :sessions_survey_fields do |t|
      t.integer :survey_id
      t.string :kind
      t.text :collection
      t.integer :max_values, default: 1
      t.integer :weight, default: 0
      t.string :name
      t.boolean :required, default: false
      t.string :entity
      t.boolean :strict_collection, default: false
      t.string :hint
      t.string :reference_type

      t.index :survey_id
    end
  end
end
