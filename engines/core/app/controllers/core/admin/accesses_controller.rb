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

      # Форматы
      header_center = workbook.add_format(align: 'center', valign: 'vcenter', text_wrap: true)
      subheader_center = workbook.add_format(align: 'center', valign: 'vcenter')
      wrap_format = workbook.add_format(text_wrap: true, valign: 'top')

      # Заголовки для проекта (двухуровневый)
      worksheet.merge_range(0, 0, 0, 1, Core::Project.model_name.human, header_center)
      worksheet.write(1, 0, 'ID', subheader_center)
      worksheet.write(1, 1, 'Название', subheader_center)
      # Ширина колонок для проекта
      worksheet.set_column(0, 0, 10, wrap_format)  # ID
      worksheet.set_column(1, 1, 30, wrap_format)  # Название

      # Остальные основные колонки: заметка, кластер, статус, начало отслеживания
      # Заметка
      worksheet.merge_range(0, 2, 1, 2, Core::ResourceControl.human_attribute_name(:note), header_center)
      worksheet.set_column(2, 2, 20)
      # Кластер
      worksheet.merge_range(0, 3, 1, 3, Core::Cluster.model_name.human, header_center)
      worksheet.set_column(3, 3, 15)
      # Статус
      worksheet.merge_range(0, 4, 1, 4, Core::ResourceControl.human_attribute_name(:status), header_center)
      worksheet.set_column(4, 4, 10)
      # Начало отслеживания
      worksheet.merge_range(0, 5, 1, 5, Core::ResourceControl.human_attribute_name(:started_at), header_center)
      worksheet.set_column(5, 5, 15)

      col = 6 # после основных колонок
      # Заголовки для каждого tracked_quota_kind
      @tracked_quota_kinds.each do |kind|
        # Объединяем ячейки в первой строке
        worksheet.merge_range(0, col, 0, col + 2, kind.to_s, header_center)
        # Подзаголовки во второй строке
        worksheet.write(1, col, '%', subheader_center)
        worksheet.write(1, col + 1, Core::ResourceControl.human_attribute_name(:consumed), subheader_center)
        worksheet.write(1, col + 2, Core::ResourceControl.human_attribute_name(:limit), subheader_center)
        col += 3
      end

      # Колонка "Доступные очереди"
      worksheet.merge_range(0, col, 1, col, Core::Access.human_attribute_name(:available_queues), header_center)

      row = 2
      @accesses.each do |access|
        resource_controls = access.resource_controls
        if resource_controls.empty?
          write_xlsx_row(worksheet, row, access, nil, @tracked_quota_kinds, wrap_format)
          row += 1
        else
          resource_controls.each do |control|
            write_xlsx_row(worksheet, row, access, control, @tracked_quota_kinds, wrap_format)
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

    def write_xlsx_row(worksheet, row, access, control, tracked_quota_kinds, wrap_format = nil)
      worksheet.write(row, 0, access.project.id, wrap_format)
      worksheet.write(row, 1, access.project.title, wrap_format)
      no_format_values = [
        control&.note,
        access.cluster.name,
        control&.human_state_name,
        control&.started_at
      ]

      tracked_quota_kinds.each do |q_k|
        field = control&.field_by_quota_kind(q_k)
        no_format_values += [field&.percentage, field&.cur_value_human, field&.limit]
      end

      no_format_values << control&.resource_control_partitions&.join(' ')
      no_format_values.each_with_index do |value, i|
        worksheet.write(row, 2 + i, value)
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
