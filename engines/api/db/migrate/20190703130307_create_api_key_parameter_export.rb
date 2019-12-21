class CreateApiKeyParameterExport < ActiveRecord::Migration
  def change
    create_table :api_key_parameter_exports, id: false do |t|
      t.belongs_to :export
      t.belongs_to :key_parameter
    end
  end
end
