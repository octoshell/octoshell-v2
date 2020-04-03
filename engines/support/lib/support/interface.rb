module Support
  class Interface

    class << self
      def handle_view(view, helper, *args)
        send(helper, view, *args)
      end

      def new_ticket_link(view)
        view.link_to view.t('support.open_support'), view.support.tickets_url
      end

      def ticket_field(args)
        ModelField.new(args)
      end
    end

  end
end
