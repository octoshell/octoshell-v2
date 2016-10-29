module Sessions
  class ReportSubmitDenialReason < ActiveRecord::Base
    validates :name, presence: true
  end
end
