module Comments
  class Admin::ContextGroupsController < Admin::ApplicationController
    def edit
      # @properties = Hash[properties]
      context_groups_options = ContextGroup.type_abs.keys
      context_groups_labels = context_groups_options.map { |o| t "types_labels.#{o}" }
      @alpaca_raw_json = {
        group_options: Group.all.map(&:id),
        group_labels: Group.all.map(&:name),
        context_options: Context.all.map(&:id),
        context_labels: Context.all.map(&:name),
        context_groups_options: context_groups_options,
        context_groups_labels: context_groups_labels
      }
    end

    def update
      type_abs = ContextGroup.type_abs
      search_hash = params.permit(:context_id, :group_id)
      context_groups = ContextGroup.where(search_hash)
      context_groups_params = params[:context_groups] || {}
      type_abs.each_key do |ab|
        exists = context_groups_params.include? ab.to_s
        if exists
          context_groups.where(type_ab: type_abs[ab]).first_or_create!
        else
          context_groups.where(type_ab: type_abs[ab]).destroy_all
        end
      end
      render json: { success: 'success' }
    end

    def type_abs
      search_hash = params.permit(:group_id, :context_id)
      context_groups = ContextGroup.where(search_hash)
      @json = {}
      ContextGroup.type_abs.each_key do |key|
        any = context_groups.any? { |d| d.type_ab == key.to_s }
        @json[key] = any
      end
      render json: @json
    end
  end
end
