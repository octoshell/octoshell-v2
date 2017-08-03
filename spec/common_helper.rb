 Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  Dir[Rails.root.join("engines/pack/spec/support/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("engines/pack/spec/factories/**/*.rb")].each { |f| require f }
    Dir[Rails.root.join("engines/comments/spec/support/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("engines/comments/spec/factories/**/*.rb")].each { |f| require f }
