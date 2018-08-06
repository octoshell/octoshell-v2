module Pack
  class Package < ActiveRecord::Base
    self.locking_column = :lock_version
    validates :name, :description, presence: true
    validates :name,uniqueness: true
    has_many :versions,:dependent => :destroy,inverse_of: :package
    scope :finder, ->(q) { where("lower(name) like lower(:q)", q: "%#{q.mb_chars}%") }

    def as_json(_options)
    { id: id, text: name }
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

    def self.allowed_for_users
      all.merge(Version.allowed_for_users)
    end

    def self.allowed_for_users_with_joins(user_id)
      all.merge(Version.allowed_for_users).joins(:versions)
         .user_access(user_id, "LEFT")
    end


    def self.user_access user_id,join_type
      if user_id == true
        user_id = 1
    end




      result = Version.join_accesses  self.joins(:versions),user_id,join_type







    end

  end

end
