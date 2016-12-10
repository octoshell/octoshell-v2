class CreatePackProjectsvers < ActiveRecord::Migration
  def change
    create_table :pack_projectsvers do |t|

      t.belongs_to :version, index: true
      t.belongs_to :core_project, index: true
      t.text :end_lic
    end
  end
end
