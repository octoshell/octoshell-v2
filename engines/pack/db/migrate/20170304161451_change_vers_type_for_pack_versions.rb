class ChangeVersTypeForPackVersions < ActiveRecord::Migration
  def change
  	change_column(:pack_versions, :vers_type, :string)
  end
end
