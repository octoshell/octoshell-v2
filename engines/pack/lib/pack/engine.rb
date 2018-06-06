module Pack
  class Engine < ::Rails::Engine
    isolate_namespace Pack
    config.to_prepare do
            Decorators.register! Engine.root, Rails.root

    end
    config.generators do |g|
       g.test_framework :rspec, :fixture => false
       g.fixture_replacement :factory_girl, :dir => 'spec/factories'
       g.assets false
       g.helper false
    end
    config.autoload_paths << File.expand_path("../app/services", __FILE__)
    puts config.autoload_paths.inspect
    # initializer "pack.add_middleware" do |app|
    #   app.middleware.use Pack::Middleware
    # end
  end

end
