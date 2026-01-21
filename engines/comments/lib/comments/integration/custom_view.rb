module Comments
  module Integration
    class CustomView < ActionView::Base
      include Engine.routes.url_helpers
      attr_reader :current_user

      def initialize(path, attach_to, attachment_type, user)
        super(path, {}, nil)

        lookup_context.view_paths.each do |resolver|
          resolver.clear_cache if resolver.respond_to?(:clear_cache)
        end

        @attach_to = attach_to
        @attachment_type = attachment_type
        @current_user = user
        model_obj = case @attachment_type
                    when 'files'
                      Comments::FileAttachment
                    when 'comments'
                      Comments::Comment
                    when 'tags'
                      Comments::Tagging
                    else
                      raise ArgumentError, 'atttachment_type is incorrect'
                    end
        if @attach_to[:class_name] == 'all'
          @records, @pages = model_obj.all_records_to_json_view(user_id: current_user.id)
        else
          @records, @pages = model_obj.to_json_view(attach_to: @attach_to, user_id: current_user.id)
          unless @attach_to[:ids] == 'all'
            @with_context = Comments::Permissions
                            .create_permissions(**@attach_to.merge(user: user))
          end
        end
        @attachable_ids = @attach_to[:ids] == 'all' ? 'all' : @attach_to[:ids].join(',')
        @contexts = Comments::Context.allow(current_user.id)
      end

      def t(arg)
        if arg.first == '.'
          arg[0] = ''
          I18n.t(arg, scope: "comments.#{@attachment_type}")
        else
          I18n.t(arg)
        end
      end

      def all?
        @attach_to[:class_name] == 'all'
      end

      def handlebars_tag(html_options = {}, &block)
        html_options = html_options.dup
        html_options[:type] = 'text/x-handlebars-template'
        content_tag(:script, html_options) do
          yield block
        end
      end
    end
  end
end
