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
    Comments.create_abilities
  end

  task create_wiki_page: :environment do
    Comments.create_wiki_page
  end
end
