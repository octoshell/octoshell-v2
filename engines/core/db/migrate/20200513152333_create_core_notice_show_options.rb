# This migration comes from core (originally 20200513152333)
class CreateCoreNoticeShowOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :core_notice_show_options do |t|
      t.belongs_to :core_user
      t.belongs_to :core_notice
      t.boolean   :hidden, default: false, null: false
      t.boolean   :resolved, default: false, null: false
      t.string    :answer, null: true
    end
  end
end
