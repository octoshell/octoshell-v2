module Pack
  class VersionOption < ActiveRecord::Base
  	attr_accessor :stale_edit
  	validate :stale_check

  	def stale_check
  		if stale_edit
  			mark_for_destruction
  			errors.add(:deleted_record,I18n.t("stale_error_nested"))
  		end
  	end

  	belongs_to :version,inverse_of: :version_options
  	validates :name,:value,:version, presence: true
  	validates_uniqueness_of :name,:scope => :version_id
  end
end
