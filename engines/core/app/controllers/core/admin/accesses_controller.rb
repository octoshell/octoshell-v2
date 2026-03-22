module Core
  class Admin::AccessesController < Admin::ApplicationController
    # before_action :setup_default_filter
    before_action :octo_authorize!
    layout 'layouts/core/admin_project'
    def index
      @search = Access.ransack(params[:q] || { queue_accesses_id_exists: true })
      @search.sorts = 'project_id desc' if @search.sorts.empty?
      @accesses = @search.result(distinct: true)
                         .select('core_accesses.*, core_accesses.project_id')
                         .page(params[:page])
                         .includes(:project, :cluster,
                                   { resource_controls: [:resource_control_fields,
                                                         {
                                                           resource_control_partitions: :partition
                                                         }] })
      @tracked_quota_kinds = Core::QuotaKind.tracked
      without_pagination :accesses
    end

    def show
      @access = Access.find(params[:id])
      @tracked_quota_kinds = Core::QuotaKind.tracked
    end

    def edit
      @access = Access.find(params[:id])
      render_edit
    end

    def update
      @access = Access.find(params[:id])
      @access.assign_attributes access_params
      if @access.save
        @access.resource_controls.each(&:enqueue_synchronize)
        redirect_to admin_access_path(@access), flash: { info: t('.success') }
      else
        render_edit
      end
    end

    def enable_resource_control
      @resource_control = ResourceControl.find(params[:id])
      @resource_control.enable!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    info: t('.success'))
    end

    def disable_resource_control
      @resource_control = ResourceControl.find(params[:id])
      @resource_control.disable!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    info: t('.success'))
    end

    def destroy_resource_control
      @resource_control = ResourceControl.find(params[:id])
      unless @resource_control.may_destroy?
        redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                      error: t('.error_not_synced'))
        return
      end
      @resource_control.destroy!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    info: t('.success'))
    end

    def sync_resource_controls
      Core::ResourceControl.all.each(&:enqueue_synchronize)
      redirect_to admin_accesses_path
    end

    def calculate_resources
      Core::SshWorker.perform_async(:calculate_resources)
      redirect_to admin_accesses_path
    end

    def send_emails_for_admins
      Core::ResourceControl.send_resource_usage_emails_for_admins
      redirect_to admin_accesses_path
    end

    def send_emails_for_users
      Core::ResourceControl.send_resource_usage_emails_for_users
      redirect_to admin_accesses_path
    end

    def export_xlsx
      require 'write_xlsx'
      require 'stringio'

      @search = Access.ransack(params[:q] || { queue_accesses_id_exists: true })
      @search.sorts = 'project_id desc' if @search.sorts.empty?
      @accesses = @search.result(distinct: true)
                         .select('core_accesses.*, core_accesses.project_id')
                         .includes(:project, :cluster,
                                   { resource_controls: [:resource_control_fields,
                                                         { resource_control_partitions: :partition }] })
      @tracked_quota_kinds = Core::QuotaKind.tracked

      buffer = StringIO.new
      workbook = WriteXLSX.new(buffer)
      worksheet = workbook.add_worksheet

      headers = [
        Core::Project.model_name.human,
        Core::Cluster.model_name.human,
        Core::ResourceControl.human_attribute_name(:status),
        Core::ResourceControl.human_attribute_name(:note),
        Core::ResourceControl.human_attribute_name(:started_at)
      ]
      @tracked_quota_kinds.each do |kind|
        headers << "#{Core::ResourceControl.human_attribute_name(:consumed)} #{kind}"
      end
      headers << Core::Access.human_attribute_name(:available_queues)

      headers.each_with_index do |header, col|
        worksheet.write(0, col, header)
      end

      row = 1
      @accesses.each do |access|
        resource_controls = access.resource_controls
        if resource_controls.empty?
          write_xlsx_row(worksheet, row, access, nil, @tracked_quota_kinds)
          row += 1
        else
          resource_controls.each do |control|
            write_xlsx_row(worksheet, row, access, control, @tracked_quota_kinds)
            row += 1
          end
        end
      end

      workbook.close
      buffer.rewind

      filename = "accesses_#{Time.current.strftime('%Y-%m-%d_%H-%M-%S')}.xlsx"
      send_data buffer.read, filename: filename,
                             type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end

    private

    def write_xlsx_row(worksheet, row, access, control, tracked_quota_kinds)
      col = 0
      # Проект
      worksheet.write(row, col, access.project.id_with_title)
      col += 1
      # Кластер
      worksheet.write(row, col, access.cluster.name)
      col += 1
      # Статус контроля ресурсов
      if control
        worksheet.write(row, col, control.human_state_name)
      else
        worksheet.write(row, col, '')
      end
      col += 1
      # Заметка
      worksheet.write(row, col, control&.note)
      col += 1
      # Отслеживание начато с
      worksheet.write(row, col, control&.started_at)
      col += 1
      # Потрачено по каждому виду квот
      tracked_quota_kinds.each do |q_k|
        field = control&.field_by_quota_kind(q_k)
        if field
          worksheet.write(row, col, field.stat)
        else
          worksheet.write(row, col, '')
        end
        col += 1
      end
      # Очереди
      if control
        worksheet.write(row, col, control.resource_control_partitions.join(' '))
      else
        worksheet.write(row, col, '')
      end
    end

    def render_edit
      @access.build_form_defaults
      flash_now_message(:error, @access.errors.full_messages.join('. ')) if @access.errors.any?
      render :edit
    end

    def access_params
      partition_attributes = %i[id _destroy
                                partition_id max_running_jobs
                                max_submitted_jobs]
      params.require(:access).permit({
                                       resource_users_attributes: %i[id member_id email _destroy],
                                       resource_controls_attributes: [:id, :started_at, :status, :_destroy, :note,
                                                                      { resource_control_fields_attributes: %i[id quota_kind_id limit],
                                                                        resource_control_partitions_attributes: partition_attributes }]
                                     })
    end
  end
end
