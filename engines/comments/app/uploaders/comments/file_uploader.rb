# encoding: utf-8

module Comments
  class FileUploader < CarrierWave::Uploader::Base
    #include CarrierWave::MimeTypes
    CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Zа-яА-ЯёЁ0-9\.\-\+_]/u

    storage :file

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "#{Rails.root}/secured_uploads/#{model.id}"
    end
  end
end
