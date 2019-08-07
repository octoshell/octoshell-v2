namespace :wikiplus do
  task create_abilities: :environment do
    puts 'Creating wikiplus abilities for groups'
    Group.all.each do |g|
      Ability.create(action: 'manage', subject: 'wikiplus',
                     group_id: g.id, available: g.name == 'superadmins')
    end
  end
end
