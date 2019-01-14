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
        view = CustomView.new(att_view_paths, @attach_to, @attachment_type,@user)
        res = view.render(file: 'from_view')
        content_tag(:div, res, id: 'res_values_att')
      end


      private

      def att_view_paths
        ActionController::Base.view_paths +
          [Comments::Engine.root + "app/views/comments/#{@attachment_type}"]
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
    end
  end
end
