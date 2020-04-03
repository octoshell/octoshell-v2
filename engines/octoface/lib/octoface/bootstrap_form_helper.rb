module Octoface
  class BootstrapFormHelper
    attr_reader :name, :options, :html_options, :f, :prefix
    def initialize(view, f, prefix = '', options = {}, html_options = {})
      @f = f
      @prefix = prefix
      @view = view
      @options = options
      @html_options = html_options
    end

    # def respond_to_missing?
    #   true
    # end

    def method_missing(name, *args, &block)
      # puts 'aaaaaaaaa'.red
      puts @view.respond_to?(name).inspect.red
      # return @view.send(name, *args, &block)
      return @view.send(name, *args, &block) if @view.respond_to?(name)

      super
    end
  end
end
