require_dependency "pack/application_controller"

module Pack
  class AccessesController < ApplicationController

    def load_for_versions
      accesses(params[:versions_ids])
      render json: @accesses_hash
    end

    def update_accesses
      @project_ids = Core::Project.joins(members: :user)
                                  .where(core_members: { user_id: current_user.id,
                                                         owner: true }).map(&:id)
      who_id = params[:type] != 'user' && params[:type].to_i
      if who_id && @project_ids.exclude?(who_id)
        render status: 400, json: { error: t('.not_owned_project') }
        return
      end
      version = Version.find(params[:version_id])
      if version.service || version.deleted
        render status: 400, json: { error: t('.unable to_create') }
        return
      end
      @access = Access.user_update(access_params, current_user.id)
      accesses(params[:versions_ids].split(','))
      if @access.is_a?(Access)
        render status: 200, json: { accesses: @accesses_hash }
      else
        render status: 400, json: { accesses: @accesses_hash,
                                    error: t(@access[:error]) }
      end
    end

    private

    def accesses(versions_ids)
      @accesses = Access.where(version_id: versions_ids)
                        .user_access(current_user.id)
                        .map do |a|
                          a.attributes.merge('end_lic' => a.end_lic.to_s,
                                             'new_end_lic' => a.new_end_lic.to_s)
                        end
      @accesses_hash = @accesses.group_by { |a| a['version_id'] }
      @accesses_hash
    end

  	def access_params
      params.permit(:id, :who_id, :who_type, :forever, :delete,
                    :version_id, :end_lic,
                    :new_end_lic, :lock_version,
                    :new_end_lic_forever, :status, :type)
    end

  end

end
