# This migration comes from core (originally 20180712114057)
class AddReasonToSureties < ActiveRecord::Migration[4.2]
  def change
    add_column :core_sureties, :reason, :text
  end
end
