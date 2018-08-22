module Sessions
  class ReportSubmitDenialReason < ActiveRecord::Base

    translates :name
    validates_translated :name, presence: true
  end
end
