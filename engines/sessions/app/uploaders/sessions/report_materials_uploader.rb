# encoding: utf-8

module Sessions
  class ReportMaterialsUploader < CarrierWave::Uploader::Base
    include CarrierWave::Compatibility::Paperclip
    storage :file

    def extension_white_list
      %w(zip rar gz 7z)
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
