module Core
  class SuretyScan < ActiveRecord::Base
    belongs_to :surety

    mount_uploader :image, SuretyScanUploader
    validates :image, presence: true
  end
end
