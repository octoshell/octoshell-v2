require "support/engine"
require "support/settings"
require "support/notificator"
require "support/markdown_handler"
require "support/interface"
require "support/model_field"

require "file_size_validator"

require 'decorators'
require 'aasm'
require 'slim'
require 'sidekiq'
# require 'maymay'
require 'ransack'
require 'kaminari'
require 'carrierwave'
require 'mime-types'

module Support
  mattr_accessor :user_class
  mattr_accessor :project_class
  mattr_accessor :dash_number

  class UserClassAbsenceError < StandardError; end
  class ProjectClassAbsenceError < StandardError; end

  class << self
    def user_class
      return unless @@user_class.is_a?(String)
      begin
        Object.const_get(@@user_class)
      rescue NameError
        @@user_class.constantize
      end
    end

    def project_class
      return unless @@project_class.is_a?(String)
      begin
        Object.const_get(@@project_class)
      rescue NameError
        @@project_class.constantize
      end
    end
  end
end
