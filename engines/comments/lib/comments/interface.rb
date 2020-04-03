module Comments
  class Interface
    class << self
      def handle_view(view, helper, *args)
        send(helper, view, *args)
      end

      def render_attachments(view, attachable, attachment_type)
        r = Integration::AttRenderer.new(attachment_type.to_s,
                                         view.current_user, attachable)
        r.render
      end

      # def render_all_attachments
      #   r = Integration::AttRenderer.new(attachment_type.to_s, view.current_user)
      #   r.render
      # end
    end
  end
end
