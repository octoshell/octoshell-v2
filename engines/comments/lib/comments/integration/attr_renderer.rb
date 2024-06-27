module Comments
  module Integration
    class AttRenderer
      include ActionView::Helpers
      A_TYPES = %w[Comment Tag File].freeze
      def initialize(attachment_type, user, attach_to = :all)
        @user = user
        @attachment_type = attachment_type
        @attach_to = hash_attach_to attach_to
        attachment_type_correct!
      end

      def render
        puts ActionController::Base.view_paths.inspect.red
        view = CustomView.with_empty_template_cache
                         .new(att_view_paths, @attach_to, @attachment_type, @user)
        res = view.render(template: 'from_view')
        content_tag(:div, res, id: 'res_values_att')
      end


      private

      def att_view_paths
        ActionView::LookupContext.new(ActionController::Base.view_paths +
          [Comments::Engine.root + "app/views/comments/#{@attachment_type}"])
      end

      def hash_attach_to(arg)
        if arg == :all
          { ids: 'all',
            class_name: 'all' }
        elsif arg.is_a?(Class) && arg < ActiveRecord::Base && !arg.is_a?(ActiveRecord::Relation)
          { class_name: arg.to_s,
            ids: 'all' }
        else
          { ids: Array(arg).map(&:id),
            class_name: Array(arg).first.class.name }
        end
      end

      def attachment_type_correct!
        unless A_TYPES.include? @attachment_type.singularize.capitalize
          raise ArgumentError, 'Invalid type'
        end
      end

      def assigns(attach_to, attachment_type, current_user)
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


        if attach_to[:class_name] == 'all'
          records, pages = model_obj.all_records_to_json_view(user_id: current_user.id)
        else
          records, pages = model_obj.to_json_view(attach_to: @attach_to, user_id: current_user.id)
          unless attach_to[:ids] == 'all'
            with_context = Comments::Permissions
                            .create_permissions(@attach_to.merge(user: current_user))
          end
        end
        { attach_to: attach_to,
          attachment_type: attachment_type,
          with_context: with_context,
          records: records,
          pages: pages,
          attachable_ids: attach_to[:ids] == 'all' ? 'all' : attach_to[:ids].join(','),
          contexts: Comments::Context.allow(current_user.id) }
      end

    end
  end
end
