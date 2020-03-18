module Sessions
  class ExternalLink
    @links = []

    class << self
      attr_accessor :links
      def link?(link)
        links.include?(link)
      end
    end
  end
  if ::Octoface.role_class?(:core, 'Project')
    ExternalLink.links << :project
  end
  
  if ::Octoface.role_class?(:core, 'Organization')
    ExternalLink.links << :organization
  end

  ::Octoface::Hook.add_hook(:sessions, "sessions/hooks/admin_users_show",
                             :main_app, :admin_users_show)

end
