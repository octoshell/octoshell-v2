class AddToToPackAccesses < ActiveRecord::Migration[5.2]
  def change
    add_reference :pack_accesses, :to, polymorphic: true
  end
end
