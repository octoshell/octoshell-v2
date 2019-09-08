module Face
  class MyMenuItem


    attr_reader :name, :url, :key

    def initialize(key, name, url, menu, *args)
      @key = key
      @name = name
      @url = url
      @controllers = args
      @menu = menu
    end

    def active?(_arg = nil)
      string = @menu.controller.params[:controller]
      first_bool = @controllers.include? string
      second_bool = @controllers.select { |c| c.is_a?(Regexp) }
                                .inject(false) do |sum, elem|
        sum || string =~ elem
      end
      first_bool || second_bool
    end
  end
end
