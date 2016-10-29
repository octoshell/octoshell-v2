# encoding: utf-8

module Announcements
  class AttachmentUploader < CarrierWave::Uploader::Base

    storage :file

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
