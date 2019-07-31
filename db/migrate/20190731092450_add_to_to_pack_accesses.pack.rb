# This migration comes from pack (originally 20190731092403)
class AddToToPackAccesses < ActiveRecord::Migration[5.2]
  def change
    add_reference :pack_accesses, :to, polymorphic: true
  end
end
