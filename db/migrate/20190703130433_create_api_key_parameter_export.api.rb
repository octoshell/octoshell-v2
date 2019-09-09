# This migration comes from api (originally 20190703130307)
class CreateApiKeyParameterExport < ActiveRecord::Migration[4.2]
  def change
    create_table :api_key_parameter_exports, id: false do |t|
      t.belongs_to :export
      t.belongs_to :key_parameter
    end
  end
end
