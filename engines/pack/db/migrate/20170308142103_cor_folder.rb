class CorFolder < ActiveRecord::Migration
  def change
  	change_column  :pack_versions,:folder,:string
  end
end
