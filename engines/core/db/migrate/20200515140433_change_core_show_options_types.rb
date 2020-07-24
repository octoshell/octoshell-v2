class ChangeCoreShowOptionsTypes < ActiveRecord::Migration[5.2]
  def change
    change_table :core_notice_show_options do |t|
      t.rename :core_user_id, :user_id
      t.rename :core_notice_id, :notice_id
    end
  end
end
