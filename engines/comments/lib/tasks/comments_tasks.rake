# desc "Explaining what the task does"
# task :comments do
#   # Task goes here
# end
namespace :comments do
  task create_abilities: :environment do
    puts 'Creating abilities for groups'
    Group.all.each do |g|
      Ability.create(action: 'manage', subject: 'comments_engine',
                     group_id: g.id, available: g.name == 'superadmins')
    end
  end

  task recreate_attachable_abilities: :environment do
    puts 'Creating abilities'
    ActiveRecord::Base.transaction do
      [Comments::ContextGroup, Comments::GroupClass, Comments::Context, Comments::FileAttachment, Comments::Tagging, Comments::Tag, Comments::Comment].each do |model|
        model.destroy_all
      end

      first_group = ['superadmins', 'paper managers', 'support', 'reregistrators'].map { |name| Group.find_by_name! name  }
      second_group = ['experts'].map { |name| Group.find_by_name! name  }
      third_group = ['superadmins', 'support'].map { |name| Group.find_by_name! name  }

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

  task create_wiki_page: :environment do
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
end
