module Pack
  module Seed
    def self.all

      # pack = create(:package)
      # version = create(:version, package: pack)
      # user= create(:user)
      unless Support::Topic.find_by(name_ru: I18n.t('integration.support_theme_name'))
        Support::Topic.create!(name_ru: I18n.t('integration.support_theme_name'))
      end


    end

    def self.create(factory_name, overrides = nil)
      FactoryBot.create(factory_name, overrides)
    end
  end
end
