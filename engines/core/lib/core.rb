require "core/engine"
require 'core/settings' if defined?(Octoface)
require "core/merge_organizations"
require "core/merge_departments"
require "core/merge_error"
require "core/checkable"
require "core/bootstrap_form_helper"

# require "maymay"
require "decorators"
require "aasm"
require "sidekiq"
require "sshkey"
require "net/ssh"
require "net/scp"
require "ransack"
require "kaminari"
require "rtf"
require "carrierwave"
require "roo"
require 'colorize'
require "core/join_orgs"
require "core/join_orgs/join_row"
require 'active_record_union'
require 'core/remove_spaces'
require 'core/interface'


module Core
  ::Octoface::Hook.add_hook(:core, "core/hooks/admin_users_show",
                            :main_app, :admin_users_show)
  mattr_accessor :user_class
  PROJECT_VERSION_START_DATE = Date.new(2023, 6, 8).freeze
  class UserClassAbsenceError < StandardError; end

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
