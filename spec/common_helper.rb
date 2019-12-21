Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }
Dir[Rails.root.join("engines/*/spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("engines/*/spec/factories/**/*.rb")].each { |f| require f }
