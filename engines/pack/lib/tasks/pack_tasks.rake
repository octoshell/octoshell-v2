namespace :pack do
  task :install => :environment do
      puts "Copying over Pack migrations..."
        Dir.chdir(Rails.root) do
          `rake pack:install:migrations`
        end

       puts "Creating abilities for groups"
      # Group.all.each do |g|
      #   Permission.first_or_create!({action: "manage",subject_class: "packages",group_id: g.id,available: (g.name=="superadmins")  } )
      # end

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

  task :migrate_pack => :environment do
    ActiveRecord::Base.transaction do
      Pack::Access.all.includes(:version).each do |a|
        next unless a.version

        a.to = a.version
        a.version = nil
        a.save!
      end

      Pack::OptionsCategory.all.each do |cat|
        OptionsCategory.find_or_create_by!(name_ru: cat.category_ru, name_en: cat.category_en)
      end
      Pack::CategoryValue.all.each do |val|
        cat = val.options_category
        new_cat = OptionsCategory.find_by!(name_ru: cat.category_ru, name_en: cat.category_en)
        CategoryValue.find_or_create_by!(value_ru: val.value_ru, value_en: val.value_en, options_category: new_cat)
      end


      Pack::VersionOption.all.each do |a|
        cat = a.options_category
        new_attributes = a.attributes.slice('name_ru','name_en', 'value_en', 'value_ru')
        new_attributes[:owner] = a.version
        if cat
          new_cat = OptionsCategory.find_by!(name_ru: cat.category_ru, name_en: cat.category_en)
          new_attributes[:options_category] = new_cat
          old_val = a.category_value
          if old_val
            new_val = new_cat.category_values.find_by!(value_ru: old_val.value_ru, value_en: old_val.value_en)
            new_attributes[:category_value] = new_val
          end
        end
        # puts a.inspect
        # puts new_attributes.inspect.red
        # puts ::Option.new(new_attributes).inspect
        ::Option.create!(new_attributes)
      end
    end
    # ::Pack::PackWorker.perform_async(:expired)
  end

end
