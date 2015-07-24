# encoding: utf-8

module Core
  class SuretyDocumentUploader < CarrierWave::Uploader::Base

    storage :file

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "uploads/#{model.class.to_s.underscore}/project_#{model.project_id}/#{mounted_as}/#{model.id}"
    end

    def extension_white_list
      %w(rtf)
    end

    # Override the filename of the uploaded files:
    # Avoid using model.id or version_name here, see uploader/store.rb for details.
    def filename
      "surety_#{Date.current.strftime("%d%m%Y")}.rtf" if original_filename.present?
    end

  end
end
