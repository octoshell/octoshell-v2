namespace :admin do
  task :add_user => :environment do
    user = User.find_by_email(ENV["EMAIL"])
    user.groups << Group.superadmins
    puts "#{ENV["EMAIL"]} has added to the superadmins group."
  end

  task :rebuild_abilities => :environment do
    Ability.redefine!
    Group.superadmins.abilities.update_all available: true
  end

  task add_new_abilities: :environment do
    Group.all.each do |g|
      g.permissions.first_or_create!(action: "manage", subject_class: "options",
                                     available: (g.name == "superadmins"))
    end
  end

  task create_abilities: :environment do
    Octoface::OctoConfig.create_abilities!
  end

end
