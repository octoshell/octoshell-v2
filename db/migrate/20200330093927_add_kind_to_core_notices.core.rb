# This migration comes from core (originally 20200330092704)
class AddKindToCoreNotices < ActiveRecord::Migration[5.2]
  def change
    change_table :core_notices do |t|
      t.string   :kind
      t.datetime :show_from
      t.datetime :show_till
      t.boolean  :active
    end
  end
end
