if (::ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false)
  Decorators.register! Rails.root, Core::Engine.root, Pack::Engine.root,
                       Sessions::Engine.root, Support::Engine.root
end
# Decorators.register! Pack::Engine.root, Rails.root
# Decorators.register! Sessions::Engine.root, Rails.root
# Decorators.register! Support::Engine.root, Rails.root
