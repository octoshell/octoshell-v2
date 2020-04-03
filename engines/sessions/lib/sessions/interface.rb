module Sessions
  class Interface
    class << self
      def handle_view(view, helper, *args)
        if args[0].is_a? ActionView::Helpers::FormBuilder
          BootstrapFormHelper.new(view, *args).try(helper)
        end
      end
    end
  end
end
