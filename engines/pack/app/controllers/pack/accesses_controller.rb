require_dependency "pack/application_controller"
require 'json'

module Pack
  class AccessesController < ApplicationController

    def load_for
      render json: accesses(params[:package_ids], params[:version_ids])
    end

    def accesses(package_ids, version_ids)
      package_relation = Access.where(to_id: package_ids,
                                      to_type: Pack::Package.to_s)
      accesses = Access.where(to_id: version_ids,
                              to_type: Pack::Version.to_s)
                       .or(package_relation)
                       .user_access(current_user.id)
      accesses.map do |a|
        a.attributes.merge('end_lic' => a.end_lic.to_s,
                           'new_end_lic' => a.new_end_lic.to_s)
      end
    end

    def accessible(class_name, id)
      raise 'error' unless ['Pack::Version', 'Pack::Package'].include? class_name
      eval(class_name).find(id)
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
      if params[:to_type] == 'Pack::Version'
        version = Version.find(params[:to_id])
        if version.service || version.deleted
          render status: 400, json: { error: t('.unable to_create') }
          return
        end
      end
      h = JSON.parse(params[:accessibles])
      @access = Access.user_update(access_params, current_user.id)
      package_ids = h['package_ids']
      version_ids = h['version_ids']
      if @access.is_a?(Access)
        render status: 200, json: { accesses: accesses(package_ids, version_ids) }
      else
        render status: 400, json: { accesses: accesses(package_ids, version_ids),
                                    error: t(@access[:error]) }
      end
    end

    private

    def localized_date date
      date.present? ? l(date) : date
    end

  	def access_params
      params.permit(:id, :who_id, :who_type, :forever, :delete,
                    :to_id, :to_type, :end_lic,
                    :new_end_lic, :lock_version,
                    :new_end_lic_forever, :status, :type)
    end

  end

end
