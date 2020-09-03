# == Schema Information
#
# Table name: pack_packages
#
#  id                  :integer          not null, primary key
#  accesses_to_package :boolean          default(FALSE)
#  deleted             :boolean          default(FALSE), not null
#  description_en      :text
#  description_ru      :text
#  name_en             :string
#  name_ru             :string
#  created_at          :datetime
#  updated_at          :datetime
#

module Pack
  class Package < ApplicationRecord



    translates :description, :name

    self.locking_column = :lock_version
    validates_translated :description,:name, presence: true
    has_many :versions,dependent: :destroy, inverse_of: :package
    has_many :accesses, dependent: :destroy, as: :to
    scope :finder, ->(q) { where("lower(name_ru) like lower(:q) OR lower(name_ru) like lower(:q)", q: "%#{q.mb_chars}%") }

    def as_json(_options)
    { id: id, text: name }
    end

    def to_s
      "#{self.class.model_name.human} \"#{name}\""
    end


    def self.ransackable_scopes(_auth_object = nil)
      %i[end_lic_greater]
    end

    def self.end_lic_greater(date)
      joins(:versions).where(['pack_versions.end_lic > ? OR pack_versions.end_lic IS NULL', Date.parse(date)])
    end

    before_save do
      if deleted == true
        versions.load
        versions.each do |v|
          v.deleted = true
          v.save
        end
      end
    end

    before_save do
      if accesses_to_package
        accesses.where(to: versions).destroy_all
      else
        accesses.where(to: self).destroy_all
      end
    end

    def self.allowed_for_users
      all.merge(Version.allowed_for_users)
    end

    def self.allowed_for_users_with_joins(user_id)
      all.merge(Version.allowed_for_users).joins(:versions)
         .user_access(user_id, "LEFT")
    end


    def self.user_access(user_id,join_type)
      if user_id == true
        user_id = 1
      end
      Version.join_accesses joins(:versions), user_id, join_type
    end

  end

end
