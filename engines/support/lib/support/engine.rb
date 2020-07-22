module Support
  class Engine < ::Rails::Engine
    isolate_namespace Support

    config.to_prepare do
      # Decorators.register! Engine.root, Rails.root
    end
    initializer 'support.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        # helper Support::ApplicationHelper
        ::ActionController::Base.send(:include, Support::ApplicationHelper)
      end
    end
  end
end
