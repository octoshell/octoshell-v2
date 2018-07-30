module Pack
  module Seed
    def self.all

      # pack = create(:package)
      # version = create(:version, package: pack)
      # user= create(:user)
      puts "SSSSS"
      unless Support::Topic.find_by(name: I18n.t('integration.support_theme_name'))
        Support::Topic.create!(name: I18n.t('integration.support_theme_name'))
      end


    end

    def self.create(factory_name, overrides = nil)
      FactoryGirl::SeedGenerator.create(factory_name, overrides)
    end
  end
end
