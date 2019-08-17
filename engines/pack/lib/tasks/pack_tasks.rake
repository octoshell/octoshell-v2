namespace :pack do
  task :install => :environment do
      puts "Copying over Pack migrations..."
        Dir.chdir(Rails.root) do
          `rake pack:install:migrations`
        end

       puts "Creating abilities for groups"
      Group.all.each do |g|
        Permission.first_or_create!({action: "manage",subject_class: "packages",group_id: g.id,available: (g.name=="superadmins")  } )
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

  task :migrate_accesses => :environment do
    ActiveRecord::Base.transaction do
      Pack::Access.all.includes(:version).each do |a|
        a.to = a.version
        a.version = nil
        a.save!
      end
    end
    # ::Pack::PackWorker.perform_async(:expired)
  end

end
