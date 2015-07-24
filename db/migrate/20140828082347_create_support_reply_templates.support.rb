# This migration comes from support (originally 20140827145721)
class CreateSupportReplyTemplates < ActiveRecord::Migration
  def change
    create_table :support_reply_templates do |t|
      t.string :subject
      t.string :message
    end
  end
end
