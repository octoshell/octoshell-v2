# == Schema Information
#
# Table name: face_users_menus
#
#  id         :bigint(8)        not null, primary key
#  menu       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#
# Indexes
#
#  index_face_users_menus_on_user_id           (user_id)
#  index_face_users_menus_on_user_id_and_menu  (user_id,menu) UNIQUE
#
module Face
  class UsersMenu < ApplicationRecord
    belongs_to :user

    validates :user, :menu, presence: true
    validates :user_id, uniqueness: { scope: :menu }

    def self.custom?(user, menu)
      where(user: user, menu: menu).exists?
    end

    def self.switch(user, menu)
      if custom?(user, menu)
        where(user: user, menu: menu).destroy_all
      else
        create!(user: user, menu: menu)
      end
    end
  end
end
