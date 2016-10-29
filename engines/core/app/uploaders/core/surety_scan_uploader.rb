# encoding: utf-8

module Core
  class SuretyScanUploader < CarrierWave::Uploader::Base
    CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Zа-яА-ЯёЁ0-9\.\-\+_]/u

    include CarrierWave::MiniMagick

    storage :file

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "uploads/#{model.class.to_s.underscore}/surety_#{model.surety_id}/#{mounted_as}/#{model.id}"
    end

    # Add a white list of extensions which are allowed to be uploaded.
    # For images you might use something like this:
    # def extension_white_list
    #   %w(jpg jpeg png pdf)
    # end

    def path
      if content_type == "application/pdf"
        ActionController::Base.helpers.image_path("core/pdf-file.jpg")
      else
        url
      end
    end
  end
end
