module Wikiplus  
  class ImageUploader < CarrierWave::Uploader::Base
    storage :file

    def store_dir
      "wikiplus/pages/pictures/:id_partition"
    end
  end
end
