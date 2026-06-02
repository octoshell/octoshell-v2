# == Schema Information
#
# Table name: wikiplus_pages
#
#  id          :integer          not null, primary key
#  content_en  :text
#  content_ru  :text
#  image       :string
#  name_en     :string
#  name_ru     :string
#  show_all    :boolean          default(TRUE)
#  sortid      :decimal(5, )
#  url         :string
#  created_at  :datetime
#  updated_at  :datetime
#  mainpage_id :integer
#
# Indexes
#
#  index_wikiplus_pages_on_mainpage_id  (mainpage_id)
#  index_wikiplus_pages_on_url          (url) UNIQUE
#
module Wikiplus
  class Page < ApplicationRecord
    def test
      id
    end

    has_many :subpages, class_name: 'Page',
                        foreign_key: 'mainpage_id'

    belongs_to :mainpage, class_name: 'Page'

    has_many :page_groups, class_name: 'Wikiplus::PageGroup', foreign_key: :page_id, dependent: :destroy
    has_many :groups, through: :page_groups, class_name: '::Group'

    translates :name, :content
    validates_translated :content, :name, presence: true
    validates :url, presence: true, uniqueness: true

    scope :visible_for, lambda { |user|
      left_joins(:page_groups)
        .where('wikiplus_page_groups.id IS NULL OR wikiplus_page_groups.group_id IN (?)',
               user.groups.select(:id))
        .distinct
    }

    def to_param
      "#{id}-#{url}"
    end
  end
end
