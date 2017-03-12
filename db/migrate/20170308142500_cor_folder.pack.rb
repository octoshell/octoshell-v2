# This migration comes from pack (originally 20170308142103)
class CorFolder < ActiveRecord::Migration
  def change
  	change_column  :pack_versions,:folder,:string
  end
end
