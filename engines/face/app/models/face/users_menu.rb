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
