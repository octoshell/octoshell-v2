# == Schema Information
#
# Table name: sessions_report_materials
#
#  id                     :integer          not null, primary key
#  materials              :string
#  materials_content_type :string
#  materials_file_size    :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  report_id              :integer
#
module Sessions
  class ReportMaterial < ActiveRecord::Base

    belongs_to :report, inverse_of: :report_materials
    mount_uploader :materials, ReportMaterialsUploader
    validates :materials, presence: true
    validates :materials, file_size: { maximum: 30.megabytes.to_i }
    before_save do
      self.materials_content_type = materials.file.content_type
      self.materials_file_size = materials.file.size
    end

  end
end
