class AddApiKeyToCoreQuotaKind < ActiveRecord::Migration[5.2]
  def change
    add_column :core_quota_kinds, :api_key, :string
  end
end
