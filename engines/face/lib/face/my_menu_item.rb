module Face
  class MyMenuItem


    attr_reader :name, :url

    def initialize(name, url, controller, *args)
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
      @controllers.include? @controller.params[:controller] # == @path[:controller]
      # puts params.inspect
      # if regexp.present?
      #   regexp =~ current_url
      # else
      #   url == current_url
      # end
    end
  end
end
