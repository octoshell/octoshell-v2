module Pack
  class Notificator < ::Support::Notificator

    def self.name_ru
      'Версии ПО с истекающей лицензией'
    end

    def self.name_en
      'Software versions with expiring license'
    end

    def topic
      Support::Topic.find_or_create_by!(name_ru: self.class.name_ru,
                                        name_en: self.class.name_en,
                                        parent_topic: parent_topic)
    end

    def notify_about_expiring_versions(versions)
      @versions = versions.includes(:package)
      hash = { subject: t('.subject') }
      hash
    end
  end
end
