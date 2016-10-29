# This migration comes from sessions (originally 20141203071736)
class AddSubmitDenialReasonAndDenialDescriptionToReports < ActiveRecord::Migration
  def change
    add_column :sessions_reports, :submit_denial_reason_id, :integer
    add_column :sessions_reports, :submit_denial_description, :text
  end
end
