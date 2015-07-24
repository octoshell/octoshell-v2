module Sessions
  class Engine < ::Rails::Engine
    isolate_namespace Sessions

    config.to_prepare do
      Decorators.register! Engine.root, Rails.root
    end

    initializer "sessions.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper Sessions::ApplicationHelper
      end
    end
  end
end
