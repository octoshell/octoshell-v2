namespace :wikiplus do
  task create_abilities: :environment do
    warn 'Creating wikiplus abilities for groups'
    Group.all.each do |g|
      Ability.create(action: 'manage', subject: 'wikiplus',
                     group_id: g.id, available: g.name == 'superadmins')
    end
  end

  task import_wiki: :environment do
    warn 'Importing wikipages from Wiki into Wikiplus...'
    Wiki::Page.all.each { |p|
      newpage = Wikiplus::Page.create(p.attributes.reject{|k,v| k=='id'})
      begin
        newpage.save
      rescue => e
        warn "Cannot import page (skipped) id=#{p.id}: #{e.message}"
      end
    }
  end

  task replace_wiki: :environment do
    warn "!!! Disable Wiki and replace it by Wikiplus.\nOld wikipages SHOULD be imported first!\nIf not, press Ctr-C in 3 seconds."
    sleep 3

    system "sed -i s/Wiki.engines_links/Wikiplus.engines_links/ '#{Rails.root}/engines/face/app/helpers/face/application_helper.rb'"
    system "sed -i s/Wiki::Page.find_or_initialize_by/Wikiplus::Page.find_or_initialize_by/ '#{Rails.root}/engines/comments/lib/comments.rb'"
    system "sed -i 's/mount Wiki::Engine/#mount Wiki::Engine/' '#{Rails.root}/config/routes.rb'"
    system "sed -i 's/gem \"wiki\",/#gem \"wiki\",/' '#{Rails.root}/Gemfile'"

    FileUtils.mv "#{Rails.root}/engines/wiki", "#{Rails.root}/wiki-old-engine"
    FileUtils.mv "#{Rails.root}/config/initializers/wiki.rb" , "#{Rails.root}/wiki-old-initializer.rb"

    warn "Please, restart octoshell-web now!"
  end
end
