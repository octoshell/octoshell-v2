# == Schema Information
#
# Table name: core_surety_scans
#
#  id        :integer          not null, primary key
#  surety_id :integer
#  image     :string(255)
#

module Core
  class SuretyScan < ActiveRecord::Base
    belongs_to :surety

    mount_uploader :image, SuretyScanUploader
    validates :image, presence: true
  end
end
