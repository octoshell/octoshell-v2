# == Schema Information
#
# Table name: sessions_report_submit_denial_reasons
#
#  id      :integer          not null, primary key
#  name_ru :string(255)
#  name_en :string
#

module Sessions
  class ReportSubmitDenialReason < ActiveRecord::Base

    has_paper_trail

    translates :name
    validates_translated :name, presence: true
  end
end
