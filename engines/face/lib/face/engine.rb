module Face
  class Engine < ::Rails::Engine
    isolate_namespace Face

    initializer "face.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper Face::ApplicationHelper
      end
    end

    config.assets.paths << "#{Face::Engine.root}/vendor/javascripts"
    config.assets.paths << "#{Face::Engine.root}/vendor/stylesheets"
  end
end
