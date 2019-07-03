class FixApiKeyParameterExport < ActiveRecord::Migration
  def change
    rename_table :api_key_parameter_exports, :api_exports_key_parameters
  end
end
