# This migration comes from sessions (originally 20190318104523)
class CreateSessionsReportMaterials < ActiveRecord::Migration
  def change
    create_table :sessions_report_materials do |t|
      t.string :materials
      t.string :materials_file_name
      t.string :materials_content_type
      t.integer :materials_file_size
      t.datetime :materials_updated_at
      t.belongs_to :report
      t.timestamps null: false
    end
  end
end
