require "support/engine"
require "file_size_validator"

require "decorators"
require "state_machine"
require "slim"
require "sidekiq"
require "maymay"
require "ransack"
require "kaminari"
require "carrierwave"
require "mime-types"

module Support
  mattr_accessor :user_class
  mattr_accessor :project_class

  class UserClassAbsenceError < StandardError; end
  class ProjectClassAbsenceError < StandardError; end

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

    def project_class
      if @@project_class.is_a?(String)
        begin
          Object.const_get(@@project_class)
        rescue NameError
          @@project_class.constantize
        end
      end
    end
  end
end
