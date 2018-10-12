require_dependency "comments/application_controller"

module Comments
  class CommentsController < ApplicationController
    def index
      if params[:attach_to][:class_name] == 'all'
        @q = Comment
        if params[:q]
          @q = @q.ransack(ransackable_params).result
          if q_params[:context_id_eq] != 'all'
            @q = @q.where(context_id: q_params[:context_id_eq])
          end
          if q_params[:attachable_type_eq] != 'all'
            @q = @q.where(attachable_type: q_params[:attachable_type_eq])
          end
          unless q_params[:attachable_id_eq].blank?
            @q = @q.where(attachable_id: q_params[:attachable_id_eq])
          end
        end
        records, pages, page = @q.all_records_to_json_view(user_id: current_user.id,
                                                     page: params[:page])
      else
        arg = params.permit(:page, attach_to: [:class_name, ids: []])
                    .to_hash
                    .dup
                    .symbolize_keys
                    .merge(user_id: current_user.id)
        arg[:attach_to].symbolize_keys!
        arg[:attach_to][:ids] ||= 'all'
        records, pages, page = Comments::Comment.to_json_view(arg)
      end
      render json: {records: records, pages: pages, page: page}
    end

    def index_all
    end

    def create
      attach_to = { class_name: comment_params[:attachable_type],
                    ids: [comment_params[:attachable_id]],
                    user: current_user
                  }
      permission = Permissions.create_permissions(attach_to)
      if comment_params[:context_id] != ' ' &&
         permission == :create_with_context &&
         Context.context_id_valid?(current_user, comment_params[:context_id])

        Comments::Comment.create!(comment_params.to_h.merge(user: current_user))
        render json: {success: true}
      elsif permission && comment_params[:context_id] == ' '
        Comments::Comment.create!(comment_params.to_h.merge(user: current_user))
        render json: {success: true}
      else
        render status: 403, json: {message: I18n.t('responses.forbidden')}
      end
    end

    def update
      @comment = Comment.where(id: comment_params[:id]).join_user_groups(current_user.id).first
      if @comment.can_update?(current_user.id)
        attach_to = { class_name: @comment.attachable_type,
                      ids: [@comment.attachable_id],
                      user: current_user
                    }
        permission = Permissions.create_permissions(attach_to)
        if permission == :create_with_context &&
           Context.context_id_valid?(current_user, comment_params[:context_id])
           @comment.update!(comment_params.slice(:text, :context_id))

        else
          @comment.update!(comment_params.slice(:text))
        end
        render json: { success: true }
      else
        render status: 403, json: { success: false }
      end
    end

    def destroy
      @comment = Comment.where(id: params[:id]).join_user_groups(current_user.id).first
      if @comment.can_update?(current_user.id)
        @comment.destroy
        render json: { success: true }
      else
        render status: 403, json: { success: false }
      end
    end

    private

    def q_params
      hash = params[:q] || {}
      hash[:context_id_eq] = nil if hash[:context_id_eq] == ' '
      hash
    end

    def comment_params
      params.require(:comment).permit(:user_id, :attachable_id,
                                      :attachable_type, :text, :context_id,:id)
    end
  end
end
