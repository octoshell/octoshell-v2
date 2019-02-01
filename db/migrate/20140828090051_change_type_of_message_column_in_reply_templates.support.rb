# This migration comes from support (originally 20140828085833)
class ChangeTypeOfMessageColumnInReplyTemplates < ActiveRecord::Migration
  def change
    change_column :support_reply_templates, :message, :text
  end
end
