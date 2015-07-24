require "core/engine"
require "maymay"
require "decorators"
require "state_machine"
require "sidekiq"
require "sshkey"
require "net/ssh"
require "net/scp"
require "ransack"
require "kaminari"
require "rtf"
require "carrierwave"

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
