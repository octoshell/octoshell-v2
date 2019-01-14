class AddReasonToSureties < ActiveRecord::Migration
  def change
    add_column :core_sureties, :reason, :text
  end
end
