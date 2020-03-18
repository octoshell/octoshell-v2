module Octoface
  class Hook
    attr_reader :name
    def initialize(role, name)
      @name = name
      role_hooks = self.class.instances[role] ||= {}

      if role_hooks[name]
        raise "You are trying to redefine #{name} hook in #{role}"
      end
      role_hooks[name] = self
    end

    def partials
      @partials ||= {}
    end

    def add_partial(from_role, partial)
      role_partials = partials[from_role] ||= []
      role_partials << partial
    end

    def render(view, maps)
      output = ''
      partials.values.each do |a|
        a.each do |partial|
          output << view.render(partial: partial, locals: maps)
        end
      end
      output.html_safe
    end

    class << self
      def instances
        @instances ||= {}
      end

      def add_hook(from_role, partial, to_role, name)
        find_or_initialize_hook(to_role, name).add_partial(from_role, partial)
      end

      def find_or_initialize_hook(role, name)
        instances[role] && instances[role][name] ||
          Octoface::Hook.new(role, name)
      end

    end
  end

  # Dir.glob(File.join(Rails.root,'engines', '*', 'app', 'hooks.rb')).each do |f|
  #   require f
  # end
end
