class AddDocumentToSurety < ActiveRecord::Migration
  def change
    add_column :core_sureties, :document, :string
  end
end
