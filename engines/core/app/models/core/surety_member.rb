module Core
  class SuretyMember < ActiveRecord::Base
    belongs_to :user, class_name: Core.user_class
    belongs_to :surety
    belongs_to :organization
    belongs_to :organization_department

    delegate :email, :full_name, to: :user
  end
end
