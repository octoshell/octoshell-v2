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
