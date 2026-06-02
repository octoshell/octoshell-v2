# == Schema Information
#
# Table name: wikiplus_page_groups
#
#  id         :integer          not null, primary key
#  page_id    :integer          not null
#  group_id   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_wikiplus_page_groups_on_page_id               (page_id)
#  index_wikiplus_page_groups_on_group_id              (group_id)
#  index_wikiplus_page_groups_on_page_id_and_group_id  (page_id, group_id) UNIQUE
#
module Wikiplus
  class PageGroup < ApplicationRecord
    belongs_to :page, class_name: 'Wikiplus::Page'
    belongs_to :group, class_name: '::Group'
  end
end
