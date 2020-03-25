# This migration comes from pack (originally 20190731091944)
class AddAccessesToPackageToPackPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :pack_packages, :accesses_to_package, :boolean, default: false
  end
end
