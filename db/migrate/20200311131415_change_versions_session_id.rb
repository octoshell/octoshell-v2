class ChangeVersionsSessionId < ActiveRecord::Migration[5.2]
  def change
    change_column :versions, :session_id, :string
  end
end
