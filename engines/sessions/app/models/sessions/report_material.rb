module Sessions
  class ReportMaterial < ActiveRecord::Base
    belongs_to :report, inverse_of: :report_materials
    mount_uploader :materials, ReportMaterialsUploader
    validates :materials, presence: true
    validates :materials, file_size: { maximum: 20.megabytes.to_i }

  end
end
