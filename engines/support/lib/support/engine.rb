module Support
  class Engine < ::Rails::Engine
    isolate_namespace Support

    config.to_prepare do
      Decorators.register! Engine.root, Rails.root
    end
  end
end
