module Core
  class RemovedMember < ApplicationRecord
    belongs_to :user, class_name: Core.user_class.to_s
    belongs_to :project, inverse_of: :removed_members
    validates :user, :project, :login, presence: true
    validates :user_id, uniqueness: { scope: %i[project_id login] }
  end
end
