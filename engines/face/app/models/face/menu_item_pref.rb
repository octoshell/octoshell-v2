module Face
  class MenuItemPref < ApplicationRecord
    belongs_to :user, class_name: Face.user_class.to_s
    validates :position, :menu, :position,:url, :user,
              presence: true, unless: proc { |pref| pref.admin }

    def self.for(user)
      where(admin: user.my_menu_pref ? false : true)
    end

    def self.last_position
      order(position: :desc).first&.position || 0
    end

  end
end
