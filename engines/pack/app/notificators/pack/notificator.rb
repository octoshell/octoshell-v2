module Pack
  class Notificator < ::Support::Notificator

    def topic_name
      t('.topic').freeze
    end

    def notify_about_expiring_versions(versions)
      @versions = versions.includes(:package)
      hash = { subject: t('.subject') }
      hash
    end
  end
end
