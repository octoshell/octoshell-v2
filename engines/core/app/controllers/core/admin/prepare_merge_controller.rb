module Core
  class Admin::PrepareMergeController < Admin::ApplicationController
    layout "layouts/core/admin_organization"
    def index
      respond_to do |format|
        format.html do
          @search = DepartmentMerger.ransack(params[:q])
          search_result = @search.result(distinct: true).order(id: :desc)
          @mergers = search_result.page(params[:page]).includes(:to_organization,:to_department,:source_department)
        end
      end
    end

    def edit
      @merger = DepartmentMerger.find(params[:id])
      @auto_core_members = Core::Member.can_be_automerged(@merger.source_department).to_a
      @auto_surety_members = Core::SuretyMember.can_be_automerged(@merger.source_department).to_a
      @core_members = Core::Member.can_not_be_automerged(@merger.source_department).to_a
      @surety_members = Core::SuretyMember.can_not_be_automerged(@merger.source_department).to_a
      @auto_open_structs = @auto_core_members.map do |p_m|
        s_m = @auto_surety_members.detect do |member|
          member.user_id == p_m.user_id &&
            member.organization_id == p_m.organization_id &&
            member.organization_department_id == p_m.organization_department_id
        end
        @auto_surety_members.delete(s_m)
        OpenStruct.new(core_member: p_m, surety_member: s_m)
      end
      @open_structs = @core_members.map do |p_m|
        s_m = @surety_members.detect do |member|
          member.user_id == p_m.user_id &&
            member.organization_id == p_m.organization_id &&
            member.organization_department_id == p_m.organization_department_id
        end
        @surety_members.delete(s_m)
        OpenStruct.new(core_member: p_m, surety_member: s_m)
      end
      @projects = Project.can_not_be_automerged(@merger.source_department).to_a
    end

    def update
      @merger = DepartmentMerger.find(permitted_params[:id])
      projects_ids = []
      surety_members_ids = []
      core_members = []

      if permitted_params[:merger][:projects]
        projects_ids = permitted_params[:merger][:projects].select do |key, value|
          value[:merge] == '1'
        end.map(&:first)
      end
      if permitted_params[:merger][:surety_members]
        surety_members_ids = permitted_params[:merger][:surety_members].select do |key, value|
          value[:merge] == '1'
        end.map(&:first)
      end
      if permitted_params[:merger][:core_members]
        core_members = permitted_params[:merger][:core_members].select do |key, value|
          value[:merge] == '1'
        end.map do |a|
          if a.second[:surety_member_id]
            [a.first, a.second[:surety_member_id]]
          else
            [a.first, nil]
          end
        end
      end
      @res = @merger.complete_merge!(projects_ids, surety_members_ids, core_members)
      if @res.instance_of? String
        @res.each { |res| flash_message :alert, res }
        edit
        render :edit
      else
        redirect_to admin_prepare_merge_index_path
      end
    end

    def destroy
      @merger = DepartmentMerger.find(params[:id])
      @merger.destroy
      redirect_to admin_prepare_merge_index_path
    end

    private

    def permitted_params
      params.permit!.to_h
    end

  end
end
