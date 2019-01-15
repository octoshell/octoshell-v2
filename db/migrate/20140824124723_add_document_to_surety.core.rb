# This migration comes from core (originally 20140824124635)
class AddDocumentToSurety < ActiveRecord::Migration
  def change
    add_column :core_sureties, :document, :string
  end
end
