module Core
  class Engine < ::Rails::Engine
    isolate_namespace Core

    config.to_prepare do
      Decorators.register! Engine.root, Rails.root
    end

    initializer "core.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper Core::ApplicationHelper
      end
    end
  end
end
