module Core
  class Admin::ClusterStatsController < Admin::ApplicationController
    before_action :octo_authorize!

    def show
      @clusters = Core::Cluster.order(:name_ru)

      return unless params[:cluster_id].present? && params[:start_date].present? && params[:end_date].present?

      cluster = Core::Cluster.find_by(id: params[:cluster_id])
      unless cluster
        flash.now[:alert] = t('.errors.cluster_not_found')
        return
      end

      start_date = parse_date(params[:start_date])
      end_date   = parse_date(params[:end_date])

      unless start_date && end_date
        flash.now[:alert] = t('.errors.invalid_date')
        return
      end

      if start_date > end_date
        flash.now[:alert] = t('.errors.start_after_end')
        return
      end

      group_by     = params[:group_by].presence || 'login'
      period_group = params[:period_group].presence || 'none'

      begin
        @result = Core::ClusterStatsService.call(
          cluster: cluster,
          start_date: start_date,
          end_date: end_date,
          group_by: group_by,
          period_group: period_group
        )
      rescue Core::ClusterStatsError => e
        flash.now[:alert] = t('.errors.service_error', message: e.message)
        Rails.logger.error "[ClusterStats] #{e.class}: #{e.message}"
      end

      @selected_cluster_id  = cluster.id
      @selected_start_date  = start_date
      @selected_end_date    = end_date
      @selected_group_by    = group_by
      @selected_period_group = period_group
    end

    def export_xlsx
      cluster = Core::Cluster.find_by(id: params[:cluster_id])
      unless cluster
        redirect_to action: :show, alert: t('.errors.cluster_not_found')
        return
      end

      start_date = parse_date(params[:start_date])
      end_date   = parse_date(params[:end_date])

      unless start_date && end_date
        redirect_to action: :show, alert: t('.errors.invalid_date')
        return
      end

      group_by     = params[:group_by].presence || 'login'
      period_group = params[:period_group].presence || 'none'

      begin
        result = Core::ClusterStatsService.call(
          cluster: cluster,
          start_date: start_date,
          end_date: end_date,
          group_by: group_by,
          period_group: period_group
        )
      rescue Core::ClusterStatsError => e
        redirect_to action: :show, alert: t('.errors.service_error', message: e.message)
        return
      end

      require 'write_xlsx'
      require 'stringio'

      buffer = StringIO.new
      workbook = WriteXLSX.new(buffer)
      worksheet = workbook.add_worksheet(t('.xlsx.sheet_name'))

      # Formats
      header_fmt = workbook.add_format(
        bold: true, align: 'center', valign: 'vcenter',
        text_wrap: true, border: 1, bg_color: '#D9E1F2'
      )
      cell_fmt = workbook.add_format(align: 'left', valign: 'vcenter', border: 1)
      number_fmt = workbook.add_format(align: 'right', valign: 'vcenter', border: 1, num_format: '#,##0.00')
      integer_fmt = workbook.add_format(align: 'right', valign: 'vcenter', border: 1, num_format: '#,##0')

      partition_columns = result[:partition_columns] || []

      # Build headers
      if period_group == 'none'
        # Row 0: Group | Total (nh, jc) | partition1 (nh, jc) | partition2 (nh, jc) | ...
        headers = [t('.xlsx.group')]
        headers << "#{t('.xlsx.total')} (#{t('.xlsx.node_hours')})"
        headers << "#{t('.xlsx.total')} (#{t('.xlsx.job_count')})"
        partition_columns.each do |part|
          headers << "#{part} (#{t('.xlsx.node_hours')})"
          headers << "#{part} (#{t('.xlsx.job_count')})"
        end
        headers.each_with_index do |h, i|
          worksheet.write(0, i, h, header_fmt)
        end
        worksheet.set_column(0, 0, 40)
        worksheet.set_column(1, 1, 15)
        worksheet.set_column(2, 2, 12)
        partition_columns.each_with_index do |_part, pi|
          worksheet.set_column(3 + pi * 2, 3 + pi * 2, 15)
          worksheet.set_column(3 + pi * 2 + 1, 3 + pi * 2 + 1, 12)
        end
      else
        # Pivot: Group | period1_total_nh | period1_total_jc | period1_part1_nh | period1_part1_jc | ...
        columns = result[:columns] || []
        headers = [t('.xlsx.group')]
        columns.each do |col|
          headers << "#{col} #{t('.xlsx.total')} (#{t('.xlsx.node_hours')})"
          headers << "#{col} #{t('.xlsx.total')} (#{t('.xlsx.job_count')})"
          partition_columns.each do |part|
            headers << "#{col} #{part} (#{t('.xlsx.node_hours')})"
            headers << "#{col} #{part} (#{t('.xlsx.job_count')})"
          end
        end
        headers.each_with_index do |h, i|
          worksheet.write(0, i, h, header_fmt)
        end
        worksheet.set_column(0, 0, 40)
        col_idx = 1
        columns.each do |_col|
          worksheet.set_column(col_idx, col_idx, 15)
          col_idx += 1
          worksheet.set_column(col_idx, col_idx, 12)
          col_idx += 1
          partition_columns.each do |_part|
            worksheet.set_column(col_idx, col_idx, 15)
            col_idx += 1
            worksheet.set_column(col_idx, col_idx, 12)
            col_idx += 1
          end
        end
      end

      row = 1

      if period_group == 'none'
        (result[:rows] || []).each do |r|
          r_total = r[:total] || {}
          worksheet.write(row, 0, r[:key], cell_fmt)
          worksheet.write(row, 1, r_total[:node_hours] || 0, number_fmt)
          worksheet.write(row, 2, r_total[:job_count] || 0, integer_fmt)
          partition_columns.each_with_index do |part, pi|
            part_cell = r.dig(:partitions, part) || {}
            worksheet.write(row, 3 + pi * 2, part_cell[:node_hours] || 0, number_fmt)
            worksheet.write(row, 3 + pi * 2 + 1, part_cell[:job_count] || 0, integer_fmt)
          end
          row += 1
        end
      else
        columns = result[:columns] || []
        (result[:rows] || []).each do |r|
          worksheet.write(row, 0, r[:key], cell_fmt)
          col_idx = 1
          columns.each do |col|
            cell = r.dig(:cells, col) || {}
            cell_total = cell[:total] || {}
            worksheet.write(row, col_idx, cell_total[:node_hours] || 0, number_fmt)
            col_idx += 1
            worksheet.write(row, col_idx, cell_total[:job_count] || 0, integer_fmt)
            col_idx += 1
            partition_columns.each do |part|
              part_cell = cell.dig(:partitions, part) || {}
              worksheet.write(row, col_idx, part_cell[:node_hours] || 0, number_fmt)
              col_idx += 1
              worksheet.write(row, col_idx, part_cell[:job_count] || 0, integer_fmt)
              col_idx += 1
            end
          end
          row += 1
        end
      end

      # Total row
      total = result[:total] || {}
      if period_group == 'none'
        worksheet.write(row, 0, t('.xlsx.total'), workbook.add_format(bold: true, border: 1))
        worksheet.write(row, 1, total[:node_hours] || 0, number_fmt)
        worksheet.write(row, 2, total[:job_count] || 0, integer_fmt)
        partition_columns.each_with_index do |part, pi|
          part_total = (result[:rows] || []).sum { |r| r.dig(:partitions, part, :node_hours) || 0 }
          part_jobs  = (result[:rows] || []).sum { |r| r.dig(:partitions, part, :job_count) || 0 }
          worksheet.write(row, 3 + pi * 2, part_total.round(2), number_fmt)
          worksheet.write(row, 3 + pi * 2 + 1, part_jobs, integer_fmt)
        end
      else
        columns = result[:columns] || []
        worksheet.write(row, 0, t('.xlsx.total'), workbook.add_format(bold: true, border: 1))
        col_idx = 1
        columns.each do |col|
          col_total_nh = (result[:rows] || []).sum { |r| r.dig(:cells, col, :total, :node_hours) || 0 }
          col_total_jc = (result[:rows] || []).sum { |r| r.dig(:cells, col, :total, :job_count) || 0 }
          worksheet.write(row, col_idx, col_total_nh.round(2), number_fmt)
          col_idx += 1
          worksheet.write(row, col_idx, col_total_jc, integer_fmt)
          col_idx += 1
          partition_columns.each do |part|
            part_total = (result[:rows] || []).sum { |r| r.dig(:cells, col, :partitions, part, :node_hours) || 0 }
            part_jobs  = (result[:rows] || []).sum { |r| r.dig(:cells, col, :partitions, part, :job_count) || 0 }
            worksheet.write(row, col_idx, part_total.round(2), number_fmt)
            col_idx += 1
            worksheet.write(row, col_idx, part_jobs, integer_fmt)
            col_idx += 1
          end
        end
      end

      workbook.close
      buffer.rewind

      filename = "cluster_stats_#{cluster.name.parameterize}_#{start_date}_#{end_date}.xlsx"
      send_data buffer.read,
                filename: filename,
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end

    private

    def parse_date(str)
      Date.parse(str.to_s)
    rescue ArgumentError
      nil
    end
  end
end
