# This migration comes from sessions (originally 20141203071540)
class CreateSessionsReportSubmitDenialReason < ActiveRecord::Migration
  def change
    create_table :sessions_report_submit_denial_reasons do |t|
      t.string :name
    end
  end
end
