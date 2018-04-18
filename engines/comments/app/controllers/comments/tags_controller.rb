require_dependency "comments/application_controller"

module Comments
  class TagsController < ApplicationController
    def index
      arg = params.permit(:page, attach_to: [:class_name, ids: []])
                  .to_hash
                  .dup
                  .symbolize_keys
                  .merge(user_id: current_user.id)
      arg[:attach_to].symbolize_keys!
      records, pages, page = Comments::Tagging.to_json_view(arg)
      render json: {records: records, pages: pages, page: page}

    end

    def create
      attach_to = { class_name: tag_params[:attachable_type],
                    ids: [tag_params[:attachable_id]],
                    user: current_user
                  }
      permission = Permissions.create_permissions(attach_to)
      if tag_params[:context_id] != ' ' &&
         permission == :create_with_context &&
         Context.context_id_valid?(current_user, tag_params[:context_id])

        Tagging.attach_tags!(tag_params.to_h.merge(user: current_user))
        render json: {success: true}
      elsif permission && tag_params[:context_id] == ' '
        Tagging.attach_tags!(tag_params.to_h.merge(user: current_user))
        render json: {success: true}
      else
        render status: 403, json: {message: I18n.t('responses.forbidden')}
      end
    end

    def destroy
      @tag = Tagging.where(id: params[:id]).join_user_groups(current_user.id).first
      if @tag.can_update?(current_user.id)
        @tag.destroy
        render json: { success: true }
      else
        render status: 403, json: { success: false }
      end
    end

    private

    def tag_params
      params.require(:tag).permit(:user_id, :attachable_id,
                                      :attachable_type, :name, :context_id, :id)
    end
  end
end
