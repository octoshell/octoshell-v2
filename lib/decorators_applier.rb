if true
# if (::ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false) &&
#     ActiveRecord::Base.connection.data_source_exists?('users')
  engine_roots = Octoface::OctoConfig.instances.values.map do |i|
    next if i.role == :main_app

    i.get_klass('Engine').root
  end.compact
  Decorators.register! Rails.root, *engine_roots

  # Decorators.register! Rails.root, Core::Engine.root, Pack::Engine.root,
  #                      Sessions::Engine.root, Support::Engine.root
end
