require "sessions/engine"
require "sessions/settings"
require "sessions/external_link"

module Sessions
  if ::Octoface.role_class?(:core, 'Project')
    add_link :project
  end

  if ::Octoface.role_class?(:core, 'Organization')
    add_link :organization
  end
end
if Sessions.link?(:project)
  require "sessions/report_project"
  require "sessions/session_project"
end
if Sessions.link?(:organization)
  require "sessions/stat_organization"
end
require "sessions/interface"
require "sessions/bootstrap_form_helper"

require "file_size_validator"

# require "maymay"
require "decorators"
#require "state_machine"
require "sidekiq"
require "ransack"
require "kaminari"
require "carrierwave"
require "aasm"

module Sessions
  mattr_accessor :user_class

  class UserClassAbsenceError < StandardError; end

  ::Octoface::Hook.add_hook(:sessions, "sessions/hooks/admin_users_show",
                            :main_app, :admin_users_show)
  class << self
    def user_class
      if @@user_class.is_a?(String)
        begin
          Object.const_get(@@user_class)
        rescue NameError
          @@user_class.constantize
        end
      end
    end
  end
end
