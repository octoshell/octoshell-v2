namespace :pack do
  task :ability => :environment do
    puts "Creating abilities for groups"
    Group.all.each do |g|
      Ability.create({action: "manage",subject: "packages",group_id: g.id,available: (g.name=="superadmins")  } )
    end
  end
  task :install => :environment do
      puts "Copying over Pack migrations..."
        Dir.chdir(Rails.root) do
          `rake pack:install:migrations`
        end

       puts "Creating abilities for groups"
      Group.all.each do |g|
        Ability.create({action: "manage",subject: "packages",group_id: g.id,available: (g.name=="superadmins")  } )
      end

      puts "Creating topic for access tickets"
      unless Support::Topic.find_by(name: I18n.t('integration.support_theme_name'))
        Support::Topic.create!(name: I18n.t('integration.support_theme_name'))
      end
      output = "\n\n" + ("*" * 53)
      output += "\nDone! Pack engine has been successfully installed."
      puts output
	end

  task :expired => :environment do
    ::Pack::PackWorker.perform_async(:expired)
  end
end
