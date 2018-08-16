module Sessions
  class ReportSubmitDenialReason < ActiveRecord::Base
    validates :name, presence: true

    translates :name

  end
end
