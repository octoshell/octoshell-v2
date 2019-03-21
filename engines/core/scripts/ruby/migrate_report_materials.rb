require 'csv'
module Sessions
  def self.save!(old_file_path, report,csv)
		# report.report_materials.destroy_all
		old_name = old_file_path.split('/')[-1]
    new_name = (old_name.split('.')[0..-2] + ['zip']).join('.')
    new_name =  Translit.convert(new_name, :english)
		old_name_splitted = old_name.split('.')

		new_name_unchanged =  (old_name_splitted[0..-2] + [old_name_splitted[-1].downcase]).join('.')
		new_name_unchanged =  Translit.convert(new_name_unchanged, :english)

    old_file = File.new(old_file_path)
    file = Tempfile.new(new_name)
    extension = old_file_path.split('.')[-1]

    new_report_material = nil
    if %w(zip rar gz 7z txt pdf).include? extension.downcase
      new_report_material =report.report_materials.new(materials:
        ActionDispatch::Http::UploadedFile.new(filename: new_name_unchanged, tempfile: old_file))
    else
      begin
        content = Zip::OutputStream.write_buffer do |stream|
            stream.put_next_entry Translit.convert(old_name, :english)
            stream.write old_file.read
        end
        file.puts content.string
        new_report_material = report.report_materials.new(materials:
          ActionDispatch::Http::UploadedFile.new(filename: new_name, tempfile: file))
      ensure
        file.close
        file.unlink
      end
    end
    unless new_report_material.save
			csv << [new_report_material.report_id, report&.materials&.file&.file,
						  new_report_material.errors.to_h, report.updated_at]
    end
    old_file.close
  end
  # zip('/home/andrey/algo_instructions.txt',Report.first)


ActiveRecord::Base.transaction do
	csv = CSV.open('migrate_reports.log','w')
	csv << %w[id file_path errors updated_at]
  Report.all.each do |report|
    puts "processing_report id: #{report.id}"
    if report.materials.file.present?
      save!(report.materials.file.file, report,csv)
    end
    # break
  end
	csv.close
end

  # [Report.first].each do |report|
  #   f = File.open('er_ticket.zip')
  #   report.materials = f
  #   report.save!
  #   f.close
  #   puts report.materials.inspect
  #   puts report.report_materials.count
  #   puts report.report_materials.inspect
  #
  #   if report.materials.present?
  #     puts 'entered'.red
  #     file = File.new(report.materials.file.file)
  #     report.report_materials.create!(materials: file)
  #   end
  #   puts report.report_materials.count
  #   puts report.report_materials.inspect
  #
  # end
end
# original_solution.files.each do |original_file|
#         f = original_file.dup
#         f.remote_name_url = original_file.name.url
#         new_solution.files << f
#       end
