namespace :api do
  task create_abilities: :environment do
    puts 'Creating abilities for groups'
    Group.all.each do |g|
      Ability.create(action: 'manage', subject: 'api_engine',
                     group_id: g.id, available: g.name == 'superadmins')
    end
  end
end
