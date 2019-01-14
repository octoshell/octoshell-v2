# This migration comes from support (originally 20180907145616)
class AddVisibleOnCreateToSupportTopics < ActiveRecord::Migration
  def change
    add_column :support_topics, :visible_on_create, :boolean, default: true
  end
end
