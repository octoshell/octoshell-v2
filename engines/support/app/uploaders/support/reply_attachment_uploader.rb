# encoding: utf-8

module Support
  class ReplyAttachmentUploader < CarrierWave::Uploader::Base
    include CarrierWave::Compatibility::Paperclip
    CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Zа-яА-ЯёЁ0-9\.\-\+_]/u

    storage :file

    def store_dir
      "system/replies/attachments/:id_partition"
    end
  end
end
