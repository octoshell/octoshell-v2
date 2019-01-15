# encoding: utf-8

module Sessions
  class ReportExportMaterialsUploader < CarrierWave::Uploader::Base
    include CarrierWave::Compatibility::Paperclip
    prepend FileTranslit
    CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Zа-яА-ЯёЁ0-9\.\-\+_]/u

    storage :file

    def store_dir
      "system/reports/materials/:id_partition"
    end
  end
end
