# This migration comes from support (originally 20180901160151)
class AddTemplateToSupportTopics < ActiveRecord::Migration
  def change
    add_column :support_topics, :template_en, :text
    add_column :support_topics, :template_ru, :text

  end
end
