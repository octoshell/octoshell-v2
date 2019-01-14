module Pack
  class Notificator < ::Support::Notificator

    def topic
      topic = super
      Support::Topic.find_or_create_by!(name_ru: t('.topic'), parent_topic: topic)
    end

    def notify_about_expiring_versions(versions)
      @versions = versions.includes(:package)
      hash = { subject: t('.subject') }
      hash
    end
  end
end
