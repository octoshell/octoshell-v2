module Pack
  if Octoface.role_class?(:support, 'Notificator')
    class Notificator < Octoface.role_class(:support, 'Notificator')
      def topic_ru
        'Версии ПО с истекающей лицензией'
      end

      def topic_en
        'Software versions with expiring license'
      end

      def notify_about_expiring_versions(versions)
        @versions = versions.includes(:package)
        { subject: t('.subject') }
      end
    end
  end
end
