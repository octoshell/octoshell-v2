module Comments
  class Admin::GroupClassesController < Admin::ApplicationController
    def edit
      group_class_radio_enums = ['none', false, true]
      group_class_radio_options = ['none', false, true].map { |e| t(".#{e}") }

      properties = GroupClass.type_abs.keys.map do |k|
        [k, { 'enum' => group_class_radio_enums, 'required' => true }]
      end
      @properties = properties.to_h
      options = GroupClass.type_abs.keys.map do |k|
        [k, { 'label' => t("types_labels.#{k}"), 'validate' => false,
              'type' => 'radio', 'optionLabels' => group_class_radio_options }]
      end
      @options = options.to_h
      @alpaca_raw_json = {
        group_options: Group.all.map(&:id),
        group_labels: Group.all.map(&:name),
        class_options: models_list,
        class_labels: ModelsList.to_a_labels,
        obj_type_options: %w[no_obj_id y_obj_id],
        properties: @properties,
        options: @options
      }
      @alpaca_raw_json[:obj_type_labels] = @alpaca_raw_json[:obj_type_options].map { |e| t ".#{e}" }
    end

    def update
      @type_abs = GroupClass.type_abs
      @search_hash = params.permit(:class_name, :obj_id)
      @search_hash[:group_id] = nil
      @search_hash[:obj_id] ||= nil

      @all_defaults = GroupClass.where(@search_hash)
      params[:class_defaults].each do |key, value|
        if value == 'none'
          @all_defaults.where(type_ab: @type_abs[key]).first_or_initialize.destroy
        else
          defa = @all_defaults.where(type_ab: @type_abs[key]).first_or_initialize
          defa.allow = value
          defa.save!
        end
      end

      @search_hash[:group_id] = params[:group_id]
      @all_groups = GroupClass.where(@search_hash)
      params[:class_groups].each do |key, value|
        if value == 'none'
          @all_groups.where(type_ab: @type_abs[key]).first_or_initialize.destroy
        else
          defa = @all_groups.where(type_ab: @type_abs[key]).first_or_initialize
          defa.allow = value
          defa.save!
        end
      end
      render json: { success: true }
    end

    # def list_objects
    #   @class_name = params[:class_name]
    #   raise "error" if models_list.exclude? @class_name
    #   @per = 5
    #   @all_records = eval(@class_name)
    #   @records = @all_records.page(params[:page]).per(@per).map(&:attributes)
    #   @pages = (@all_records.count.to_f / @per).ceil
    #   render json: {records: @records, pages: @pages }
    # end

    def type_abs
      obj_id = params[:obj_id] == '' ? nil : params[:obj_id]
      @defaults_hash = {
        class_name: params[:class_name],
        obj_id: obj_id,
        group_id: nil
      }
      @groups_hash = @defaults_hash.dup
      @groups_hash[:group_id] = params[:group_id]
      @defaults = GroupClass.where(@defaults_hash).to_a
      @groups = GroupClass.where(@groups_hash).to_a
      @defaults_json = {}
      @groups_json = {}
      GroupClass.type_abs.each_key do |key|
        record = @defaults.detect { |d| d.type_ab == key.to_s }
        @defaults_json[key] = record ? record.allow : nil

        group_record = @groups.detect { |d| d.type_ab == key.to_s }
        @groups_json[key] = group_record ? group_record.allow : nil
      end

      render json: { defaults: @defaults_json, groups: @groups_json }
    end

    private

    # def group_class_params
    #   params.require(:group_class).permit(:user_id, :attachable_id,
    #                                   :attachable_type, :text)
    # end

    def models_list
      ModelsList.to_a
    end
  end
end
