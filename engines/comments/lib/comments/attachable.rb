module Comments
  module Attachable
    extend ActiveSupport::Concern
    included do
      validates :user, :attachable, presence: true
      belongs_to :attachable, polymorphic: true
      belongs_to :user
      belongs_to :context
    end

    def can_update?(user_id)
      upd || self.user_id == user_id
    end

    def attachable_name
      attachable.try(:attachable_name) || attachable.try(:name) ||
        attachable.try(:title) || attachable.try(:id)
    end

    def attachable_class_name
      attachable.class.model_name.human
    end

    def attachable_to_json
      { attachable_class: attachable_class_name,
        attachable_name: attachable_name }
    end

    module ClassMethods
      def get_items(arg)
        arg = arg.to_a if arg.is_a?(ActiveRecord::Relation) && arg.loaded?
        if arg.is_a? ActiveRecord::Relation
          join_table = arg.table_name
          joins("INNER JOIN #{join_table} on
            #{join_table}.id = #{table_name}.attachable_id
            AND #{table_name}.attachable_type = '#{arg.klass.name}' ")
            .merge(arg)
        elsif arg.is_a? Array
          unless arg.empty? || arg.all? { |x| x.is_a? arg.first.class }
            raise ArgumentError, 'Argument must be an array of elements of the same class'
          end

          ids = arg.map(&:id)
          where(attachable_type: arg.first.class.name, attachable_id: ids)
        elsif arg.instance_of? Hash
          if arg[:ids] == 'all'
            where(attachable_type: arg[:class_name])
          else
            where(attachable_type: arg[:class_name], attachable_id: arg[:ids])
          end
        elsif arg.respond_to? :id
          get_items [arg]
        else
          raise ArgumentError
        end
      end

      def join_user_groups(user_id)
        join_user_groups_with_context(user_id).union(
          join_user_groups_without_context(user_id)
        )
      end

      # def join_user_groups(user_id)
      #     join_user_groups_without_context(user_id)
      # end

      def join_user_groups_with_context(user_id)
        select("#{table_name}.*,CAST(MAX(u_c_g.id) AS BOOLEAN ) AS upd")
          .joins("LEFT JOIN user_groups AS u_g ON u_g.user_id=#{user_id}")
          .joins("INNER JOIN comments_context_groups AS c_g ON
          c_g.context_id = #{table_name}.context_id AND
          c_g.group_id = u_g.group_id AND c_g.type_ab = #{ContextGroup.type_abs[:read_ab]}")
          .joins("LEFT JOIN comments_context_groups AS u_c_g ON u_c_g.context_id = #{table_name}.context_id AND
          u_c_g.group_id = u_g.group_id AND u_c_g.type_ab = #{ContextGroup.type_abs[:update_ab]}")
          .group(:id)
      end

      def join_user_groups_without_context(user_id)
        g_c = 'up_g_c'
        null_g_c = 'null_up_g_c'
        upd = "(MAX((#{null_g_c}.allow = 'f' AND #{g_c}.allow = 't' OR
                    #{null_g_c}.allow = 't' AND ( #{g_c}.allow = 't' OR #{g_c}.id IS NULL)
               )::int) = 1)AS upd"
        select("#{table_name}.*," + upd).group(:id)
                                        .joins("LEFT JOIN user_groups AS u_g ON u_g.user_id=#{user_id}")
                                        .join_read
                                        .join_spec(g_c, null_g_c, :update_ab)
      end

      def read_items(arg, user_id)
        get_items(arg).join_user_groups(user_id).order(updated_at: :desc)
      end

      def join_spec(g_c, null_g_c, type_ab)
        joins("LEFT JOIN comments_group_classes AS #{null_g_c} ON
          #{null_g_c}.class_name = #{table_name}.attachable_type AND
          (#{null_g_c}.obj_id IS NULL OR
            #{null_g_c}.obj_id = #{table_name}.attachable_id)
            AND #{null_g_c}.group_id IS NULL
            AND #{null_g_c}.type_ab =  #{GroupClass.type_abs[type_ab]} ")
          .joins("LEFT JOIN comments_group_classes AS #{g_c} ON
          #{g_c}.class_name = #{table_name}.attachable_type AND
          (#{g_c}.obj_id IS NULL OR #{g_c}.obj_id = #{table_name}.attachable_id)
          AND #{g_c}.group_id = u_g.group_id
          AND #{g_c}.type_ab =  #{GroupClass.type_abs[type_ab]}")
      end

      def join_read
        g_c = 'read_g_c'
        null_g_c = 'read_null_g_c'
        join_spec(g_c, null_g_c, :read_ab)
          .where("( #{null_g_c}.allow = 'f' AND #{g_c}.allow = 't' OR
            #{null_g_c}.allow = 't' AND ( #{g_c}.allow = 't' OR #{g_c}.id IS NULL)   ) AND
            #{table_name}.context_id IS NULL")
      end

      def pag_records(attach_to:, per:, user_id:, includes:, page: nil)
        relation = read_items(attach_to, user_id).includes(includes)
        pag_records_common(relation: relation, page: page, per: per)
      end

      def pag_all_records(user_id:, per:, includes:, page: nil)
        relation = join_user_groups(user_id).includes(includes)
        pag_records_common(relation: relation, page: page, per: per)
      end

      def pag_records_common(relation:, page:, per:)
        count = relation.count
        pages = (count.to_f / per).ceil
        page ||= 1
        corrected_page = page.to_i > pages ? pages : page
        [relation.page(corrected_page).per(per), pages, corrected_page]
      end
    end
  end
end
