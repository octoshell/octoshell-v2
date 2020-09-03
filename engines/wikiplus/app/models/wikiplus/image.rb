# == Schema Information
#
# Table name: wikiplus_images
#
#  id         :integer          not null, primary key
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Wikiplus
  class Image < ActiveRecord::Base
  	mount_uploader :image, ImageUploader
  end
end
