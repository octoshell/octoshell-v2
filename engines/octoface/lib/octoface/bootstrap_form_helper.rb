module Octoface
  class BootstrapFormHelper
    attr_reader :name, :options, :html_options, :f, :prefix
    # def initialize(view, f, prefix = '', options = {}, html_options = {})
    def initialize(view, f, *args)
      if args.first.is_a?(String)
        @prefix, @options, @html_options = *args
      else
        @prefix = ''
        @options, @html_options = *args
      end
      @options ||= {}
      @html_options ||= {}

      @f = f
      @view = view
    end

    def method_missing(name, *args, &block)
      return @view.send(name, *args, &block) if @view.respond_to?(name)

      super
    end
  end
end
