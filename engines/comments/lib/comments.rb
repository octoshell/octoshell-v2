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
  # mattr_accessor :wiki_id
  # def self.init_wiki_page
  #   unless Rails.env.test?
  #     url = 'comments_guide'
  #     page = Wiki::Page.find_by(url: url)
  #     if page
  #       self.wiki_id = page.id
  #     end
  #   end
  # end
  def self.create_wiki_page
    readme_md_path = "#{Comments::Engine.root}/Readme.md"
    regexp = Regexp.new I18n.t('comments.rake.regexp')
    url = I18n.t('comments.rake.url')
    name = I18n.t('comments.rake.name')
    wiki_body = ''
    flag = false
    File.open(readme_md_path).each_line do |line|
      line =~ regexp && flag = true
      flag && wiki_body << line
    end
    page = Wiki::Page.find_or_initialize_by(url: url)
    !page.new_record? && puts('Comments wiki page exists')
    page.content = wiki_body
    page.name = name
    page.save!
    puts 'Wiki page has been created or edited'
  end

  def self.create_abilities
    puts 'Creating abilities'
    ActiveRecord::Base.transaction do
      # [Comments::ContextGroup, Comments::GroupClass, Comments::Context, Comments::FileAttachment, Comments::Tagging, Comments::Tag, Comments::Comment].each do |model|
      #   model.destroy_all
      # end

      first_group = ['superadmins', 'paper managers', 'support', 'reregistrators'].map { |name| Group.find_by_name name  }.compact
      second_group = ['experts'].map { |name| Group.find_by_name name }.compact
      third_group = ['superadmins', 'support'].map { |name| Group.find_by_name name }.compact

      admin_context = Comments::Context.create!(name: 'Cмотреть всем, кроме экспертов')

      first_group.each do |group|
        Comments::ContextGroup.type_abs.map(&:second).each do |type|
          Comments::ContextGroup.create!(context: admin_context, group: group, type_ab: type)
        end
      end

      [::User, Core::Project, Sessions::UserSurvey, Core::Organization, Pack::Package, Sessions::Report].each do |model|
        Comments::GroupClass.type_abs.map(&:second).each do |type|
          Comments::GroupClass.create!(class_name: model.to_s, group: nil, allow: false,type_ab: type)
        end
        first_group.each do |group|
          Comments::GroupClass.type_abs.map(&:second).each do |type|
            Comments::GroupClass.create!(class_name: model.to_s, group: group, allow: true,type_ab: type)
          end
        end
        second_group.each do |group|
          %i[create_ab read_ab update_ab].each do |type|
            Comments::GroupClass.create!(class_name: model.to_s, group: group, allow: true,type_ab: type)
          end
        end
      end

      Comments::GroupClass.type_abs.map(&:second).each do |type|
        Comments::GroupClass.create!(class_name: Support::Ticket, group: nil, allow: false,type_ab: type)
      end

      third_group.each do |group|
        Comments::GroupClass.type_abs.map(&:second).each do |type|
          Comments::GroupClass.create!(class_name: Support::Ticket, group: group, allow: true,type_ab: type)
        end
      end
    end
  end
end
