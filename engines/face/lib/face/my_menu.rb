module Face
  class MyMenu

    delegate :can?, :t, :current_user, to: :@controller
    include ActionDispatch::Routing::RouteSet::MountedHelpers
    #
    # MountedHelpers = ActionDispatch::Routing::RouteSet::MountedHelpers
    @instances ||= {}
    attr_reader :blocks, :name
    def initialize(name)
      @name = name
      @blocks = []
      @items = []
    end

    def add_item(key, name, url, *args)
      @items << MyMenuItem.new(key, name, url, @controller, *args)
    end

    def add_item_if_may(key, name, url, *args)
      abilities = Octoface.action_and_subject_by_path(*args.first)
      return unless can?(*abilities)

      @items << MyMenuItem.new(key, name, url, @controller, *args)
    end

    def items_from_db(controller)
      conditions = if UsersMenu.custom?(controller.current_user, name)
                     { admin: false, user: controller.current_user, menu: name }
                   else
                     { admin: true, menu: name }
                   end
      prefs = MenuItemPref.where(conditions).order(:position).to_a
      items = items(controller).dup
      results = []
      prefs.each do |pref|
        result = items.detect { |i| i.key == pref.key }
        if result
          results << result
          items.delete result
        else
          pref.destroy!
        end
      end
      results += items
      results
    end

    def items(controller)
      @controller = controller
      @items.clear
      @blocks.each do |block|
        instance_eval &block
      end
      # conditions = {user: @user, admin: true, }
      @items
    end

    def method_missing(m, *args, &block)
      # puts ActionDispatch::Routing::RouteSet::MountedHelpers.instance_methods.sort.inspect.red
      @controller.send(m, *args, &block)
    end

    def self.items_for(name, &block)
      instance = @instances[name]
      if instance
        @instances[name].blocks << block
        return
      else
        if singleton_methods.include?(name)
          raise 'Please provide name which is not included in singleton_methods'
        end

        define_singleton_method(name) do |controller|
          @instances[name].items_from_db(controller)
        end
        @instances[name] = new(name)
        @instances[name].blocks << block
      end
    end

    def self.validate_keys!
      # Octoshell::Application.routes.eager_load!
      # puts ActionDispatch::Routing::RouteSet::MountedHelpers.respond_to?(:session).inspect.red
      # puts ActionDispatch::Routing::RouteSet::MountedHelpers.methods.sort.inspect.red
      fake_controller = Class.new(::ApplicationController) do
        # include app.routes.mounted_helpers
        # include ActionDispatch::Routing::RouteSet::MountedHelpers
        def current_user
          User.superadmins.new
        end

        def can?(*_args)
          true
        end
        # def method_missing(m, *args, &block)
        #   # fake_controller.send(m, *args, &block)
        #   # nil
        # end
      end
      # fake_controller.include ActionDispatch::Routing::RouteSet::MountedHelpers

      # fake_controller = Class.new(ActionController::Base)
      # fake_controller.include ActionDispatch::Routing::RouteSet::MountedHelpers

      # puts fake_controller.new.methods(true).sort.inspect.red
      # puts fake_controller.new.announcements.methods(true).sort.inspect.red

      @instances.each_value do |value|
        keys = value.items(fake_controller.new).map(&:key)
        key = keys.detect { |k| keys.count(k) > 1 }
        raise "#{key} is specified twice" if key
        conditions = { menu: value.name.to_s, admin: true }
        keys.each do |k|
          # puts conditions.merge(key: k).inspect.red
          # MenuItemPref.create!(conditions.merge(key: k, position: MenuItemPref.last_position + 1))

          rel = MenuItemPref.where(conditions.merge(key: k))
          # puts MenuItemPref.where(conditions).last_position.inspect.red
          rel.first_or_create!(position: MenuItemPref.where(conditions).last_position + 1)

          # MenuItemPref.create_with(position: MenuItemPref.last_position + 1)
          #             .find_or_create_by!(conditions.merge(key: k))

        end
      end
    end
  end
end
