# == Schema Information
#
# Table name: core_surety_scans
#
#  id        :integer          not null, primary key
#  image     :string(255)
#  surety_id :integer
#
# Indexes
#
#  index_core_surety_scans_on_surety_id  (surety_id)
#

module Core
  class SuretyScan < ApplicationRecord
    belongs_to :surety

    mount_uploader :image, SuretyScanUploader
    validates :image, presence: true
  end
end
