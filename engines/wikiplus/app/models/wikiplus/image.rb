module Wikiplus
  class Image < ActiveRecord::Base
  	mount_uploader :image, ImageUploader
  end
end
