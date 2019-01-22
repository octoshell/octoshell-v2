require "comments/engine"
require "comments/attachable"
require "comments/integration"
require "comments/integration/attr_renderer"
require "comments/integration/custom_view"
require "comments/permissions"
require "comments/models_list"
require 'translit'
require 'active_record_union'
module Comments
  mattr_accessor :inline_types
  mattr_accessor :wiki_id
  def self.init_wiki_page
    unless Rails.env.test?
      url = 'comments_guide'
      page = Wiki::Page.find_by(url: url)
      if page
        self.wiki_id = page.id
      end
    end
  end
end
