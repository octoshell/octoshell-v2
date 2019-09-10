# == Schema Information
#
# Table name: user_groups
#
#  id       :integer          not null, primary key
#  group_id :integer
#  user_id  :integer
#
# Indexes
#
#  index_user_groups_on_group_id  (group_id)
#  index_user_groups_on_user_id   (user_id)
#

# Связь пользователя и группы
class UserGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
end
