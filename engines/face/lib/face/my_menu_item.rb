module Face
  class MyMenuItem


    attr_reader :name, :url, :key

    def initialize(key, name, url, controller, *args)
      @key = key
      @name = name
      @url = url
      @controller = controller
      @controllers = args
    end

    # def path
    #   Rails.application.routes.url_helpers.module_exec &@path
    # end

    def active?(_arg = nil)
      # puts params.methods(true)
      # puts params.fetch(:controller, :action)
      # puts @controllers.inspect.red
      # puts controller.params[:controller].inspect.red
      string = @controller.params[:controller]
      first_bool = @controllers.include? string # == @path[:controller]
      second_bool = @controllers.select { |c| c.is_a?(Regexp) }
                                .inject(false) do |sum, elem|
        sum || string =~ elem
      end
      # [].map { |c| c.is_a?(Regexp) }.inject(false) { |sum, elem| sum || elem }
      first_bool || second_bool
      # puts params.inspect
      # if regexp.present?
      #   regexp =~ current_url
      # else
      #   url == current_url
      # end
    end
  end
end
