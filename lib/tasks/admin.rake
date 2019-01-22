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
end
