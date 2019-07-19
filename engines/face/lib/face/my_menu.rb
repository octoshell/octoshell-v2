module Face
  class MyMenu

    @instances ||= {}

    attr_reader :blocks
    def initialize
      @blocks = []
      @items = []
    end

    def add_item(name, hash, *args)
      @items << MyMenuItem.new(name, hash, @controller, *args)
    end

    def items(controller)
      @controller = controller
      @items.clear
      @blocks.each do |block|
        instance_eval &block
      end
      @items
    end

    def method_missing(m, *args, &block)
      @controller.send(m, *args, &block)
    end

    def self.first_or_new(name, &block)
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
        @instances[name] = new
        @instances[name].blocks << block
      end
    end
  end
end
