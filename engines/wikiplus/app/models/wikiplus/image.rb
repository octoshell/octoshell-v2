module Wikiplus
  class Image < ApplicationRecord
  	mount_uploader :image, ImageUploader
  end
end
