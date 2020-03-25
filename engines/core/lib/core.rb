require "core/engine"
require "core/merge_organizations"
require "core/merge_departments"
require "core/merge_error"
require "core/checkable"
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


module Core
  mattr_accessor :user_class

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
