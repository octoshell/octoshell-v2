namespace :reports do
  task :install => :environment do
  	puts "Copying over Reports migrations..."
    Dir.chdir(Rails.root) do
      `rake reports:install:migrations`
    end

    puts "Creating abilities for groups"
    Group.all.each do |g|
      Ability.create({action: "manage",subject: "reports_engine",group_id: g.id,available: (g.name=="superadmins")  } )
    end
    puts "\nDone! Reports engine has been successfully installed."
	end
end
