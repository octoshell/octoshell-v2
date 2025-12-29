# == Schema Information
#
# Table name: core_removed_members
#
#  id         :bigint(8)        not null, primary key
#  login      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_core_removed_members_on_project_id  (project_id)
#  index_core_removed_members_on_user_id     (user_id)
#
module Core
  class RemovedMember < ApplicationRecord
    belongs_to :user, class_name: Core.user_class.to_s
    belongs_to :project, inverse_of: :removed_members
    validates :user, :project, :login, presence: true
    validates :user_id, uniqueness: { scope: %i[project_id login] }
  end
end
