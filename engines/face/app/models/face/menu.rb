module Face
  class Menu
    def initialize
      Thread.current[:menu_items] ||= Set.new
      @items = Thread.current[:menu_items]
    end

    def items
      @items
    end

    def add_item(item)
      @items << item
    end
  end
end
