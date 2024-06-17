
module Comments
  class FilesController < ApplicationController
    def index
      if params[:attach_to][:class_name] == 'all'
        @q = FileAttachment
        if params[:q]
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
        records, pages, page = Comments::FileAttachment.to_json_view(arg)
      end
      render json: {records: records, pages: pages, page: page}
    end

    def create
      attach_to = { class_name: file_params[:attachable_type],
                    ids: [file_params[:attachable_id]],
                    user: current_user
                  }
      permission = Permissions.create_permissions(attach_to)
      if file_params[:context_id] != ' ' &&
         permission == :create_with_context &&
         Context.context_id_valid?(current_user, file_params[:context_id])

        FileAttachment.create! create_params
        render json: {success: true}
      elsif permission && file_params[:context_id] == ' '
        FileAttachment.create! create_params
        render json: {success: true}
      else
        render status: 403, json: {message: I18n.t('responses.forbidden')}
      end
    end

    def show_file
      ending = request.original_url.split('/').last
      @can_read = FileAttachment.where(id: params[:id]).join_user_groups(current_user.id).exists?
      file_path = "#{Rails.root}/secured_uploads/#{params[:id]}/#{ending}"
      if @can_read
        send_file(file_path, disposition: disposition(ending))
      else
        raise 'error'
      end
    end

    def update
      @attachment = FileAttachment.where(id: file_params[:id]).join_user_groups(current_user.id).first
      if @attachment.can_update?(current_user.id)
        attach_to = { class_name: @attachment.attachable_type,
                      ids: [@attachment.attachable_id],
                      user: current_user
                    }
        permission = Permissions.create_permissions(attach_to)
        if permission == :create_with_context &&
           Context.context_id_valid?(current_user, file_params[:context_id])
           @attachment.update!(file_params.slice(:description, :context_id))
        else
          @attachment.update!(file_params.slice(:description))
        end
        render json: { success: true }
      else
        render status: 403, json: { success: false }
      end
    end


    def destroy
      @tag = FileAttachment.where(id: params[:id]).join_user_groups(current_user.id).first
      if @tag.can_update?(current_user.id)
        @tag.destroy
        render json: { success: true }
      else
        render status: 403, json: { success: false }
      end
    end

    private

    def inline_types
      Comments.inline_types
    end

    def disposition(file_name)
      file_format = file_name.split('.').last
      return 'inline' if inline_types.include? file_format
      'attachment'
    end

    def q_params
      hash = params[:q] || {}
      hash[:context_id_eq] = nil if hash[:context_id_eq] == ' '
      hash
    end

    def create_params
      res_params = file_params.to_h.merge(user: current_user)
      file = res_params['file']
      file.original_filename = Translit.convert(file.original_filename, :english)
      res_params
    end

    def file_params
      params.permit(:user_id, :attachable_id,
                    :attachable_type, :description, :context_id, :file, :id)
    end
  end
end
