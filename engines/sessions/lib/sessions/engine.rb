module Sessions
  class Engine < ::Rails::Engine
    isolate_namespace Sessions

    config.to_prepare do
      Decorators.register! Engine.root, Rails.root
    end

    # initializer 'local_helper.action_controller' do
    #     ActiveSupport.on_load :action_controller do
    #       helper GemName::ApplicationHelper
    #     end
    # end
    # initializer "sessions.action_controller" do |app|
    #   ActiveSupport.on_load :action_controller do
    #     #helper Sessions::ApplicationHelper
    #     ::ActionController::Base.send(:include, Sessions::ApplicationHelper)
    #   end
    # end
  end
end
