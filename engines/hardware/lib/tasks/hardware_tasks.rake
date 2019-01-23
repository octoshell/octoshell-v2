namespace :hardware do
  task :install => :environment do
    puts "Copying over Hardware migrations..."
    Dir.chdir(Rails.root) do
      `rake hardware:install:migrations`
    end

     puts "Creating abilities for groups"
    Group.all.each do |g|
      Ability.find_or_create_by!({action: "manage",subject: "hardware",group_id: g.id,available: (g.name=="superadmins")  } )
    end
    output = "\n\n" + ("*" * 53)
    output += "\nDone! Hardware engine has been successfully installed."
    puts output
  end
end
