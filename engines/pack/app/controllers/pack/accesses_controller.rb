require_dependency "pack/application_controller"

module Pack
  class AccessesController < ApplicationController
    def access_init
      @access = Access.find(params[:id])
    end

    def load_for_versions
      @accesses = Access.where(version_id: params[:versions_ids])
                        .user_access(current_user.id)
      @accesses_hash = @accesses.group_by(&:version_id)
      render json: @accesses_hash

      # t.integer  "version_id"
      # t.integer  "who_id"
      # t.string   "who_type"
      # t.string   "status"
      # t.integer  "created_by_id"
      # t.datetime "created_at"
      # t.datetime "updated_at"
      # t.date     "end_lic"
      # t.date     "new_end_lic"
      # t.integer  "allowed_by_id"

    end

    def update_old
      begin
        @vers_id=access_params[:version_id]
        @version=Version.find(@vers_id)
        if @version.service || @version.deleted
          raise ActiveRecord::RecordNotFound
        end
        @access=Access.user_update(access_params,current_user.id)
        @access.user_edit= true
        @access.created_by_id=current_user.id unless @access.created_by
        if @access.save

          @to='success'
          render "form"
        else
           render_template
        end
        rescue ActiveRecord::StaleObjectError
          @message=t("stale_message")
          @access.restore_attributes
          render_template
        rescue ActiveRecord::RecordNotFound
          @message=t("stale_message") + t("exception_messages.refresh_page")
          render_template
      end
    end

    def update_accesses
      version = Version.find(params[:version_id])
      if version.service || version.deleted
        render status: 400, json: { error: t('.unable to_create')}
      end
      @access = Access.user_update(access_params, current_user.id)
      @accesses = Access.where(version_id: params[:versions_ids].split(','))
                        .user_access(current_user.id)
      @accesses_hash = @accesses.group_by(&:version_id)
      if @access.is_a?(Access)
        render status: 200, json: { accesses: @accesses_hash }
      else
        render status: 400, json: { accesses: @accesses_hash, error: t(@access[:error]) }
      end
    end






    def destroy
      begin
        @to='delete_success'
        @vers_id=access_params[:version_id]
        @access=Access.find(access_params[:id])

        @access.status='deleted' if @access.status=='requested'
        @access.user_edit= true
        @access.save!

      rescue ActiveRecord::StaleObjectError
          @to='delete_not_success'
          @message=t("stale_message")
      rescue ActiveRecord::RecordNotFound
          @to='delete_not_success'
          @message=t("exception_messages.not_found")
      end
      render "form"

    end


  	def form
      begin
        @vers_id=params[:version_id]
        Version.find(@vers_id)

        @access=Access.search_access( params,current_user.id)
        render_template
      rescue ActiveRecord::RecordNotFound
          @message=t("stale_message") + t("exception_messages.refresh_page")
          render "form"

      end

    end

    def render_template

        if @access
          if @access.new_record?
            @to='form'

          else
            case @access.status
              when 'requested'
                @to='delete'
              when 'allowed'
                @to='allowed'
              when 'denied'
                @to='denied'
              when 'expired'
                @to='allowed'
              when 'deleted'
                @to='deleted'
              else
                raise 'Error in @access status'
            end
          end
        end

      render "form"

    end


  	def access_params
      params.permit(:id, :who_id, :who_type, :forever, :delete,
                                     :version_id, :end_lic,
                                     :new_end_lic, :lock_version,
                                     :new_end_lic_forever, :status, :type)
    end

  end

end
