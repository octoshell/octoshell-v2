module Face
  class MyMenu
    MountedHelpers = ActionDispatch::Routing::RouteSet::MountedHelpers
    @instances ||= {}

    attr_reader :blocks
    def initialize(name)
      @name = name
      @blocks = []
      @items = []
    end

    def add_item(name, url, *args)
      @items << MyMenuItem.new(name, url, @controller, *args)
    end

    def add_item_if_may(name, hash, *args)
      abilities = Octoface.action_and_subject_by_path(*args.first)
      return unless can?(*abilities)

      @items << MyMenuItem.new(name, hash, @controller, *args)
    end

    def items(controller)
      # puts controller.core.class.green
      # puts mounted_helpers.inspect.green
      # puts controller.methods.sort.inspect.red

      @controller = controller
      @items.clear
      @blocks.each do |block|
        instance_eval &block
      end
      @items
    end

    def method_missing(m, *args, &block)
      puts ActionDispatch::Routing::RouteSet::MountedHelpers.instance_methods.sort.inspect.red
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
          @instances[name].items(controller)
        end
        @instances[name] = new(name)
        @instances[name].blocks << block
      end
    end
  end
end
