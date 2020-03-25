module Face
  class MenuItemsController < Face::ApplicationController
    before_action :require_login
    def edit_all
      @menu = params[:menu] || 'user_submenu'
      if params[:subject] == 'switch'
        UsersMenu.switch(current_user, @menu)
      end

      if UsersMenu.custom?(current_user, @menu)
        if params[:subject] == 'copy_from_default'
          Face::MenuItemPref.where(menu: @menu, user: current_user,
                                   admin: false).destroy_all
        end

        if Face::MenuItemPref.where(menu: @menu, user: current_user,
                                    admin: false).empty?
          Face::MenuItemPref.where(menu: @menu, admin: true).to_a.each do |pref|
            new_pref = pref.dup
            new_pref.user = current_user
            new_pref.admin = false
            new_pref.save!
          end
        end
      end

    end

    def update_all
      conditions = { menu: params[:menu],
                     admin: !UsersMenu.custom?(current_user, params[:menu]), user: current_user }
      if conditions[:admin]
        unless User.superadmins.include?(current_user)
          render plain: t('.not_allowed_to_edit')
          return
        end
        conditions[:user] = nil
      end
      MenuItemPref.edit_all(params[:keys], conditions)
      render plain: t('.saved')
    end
  end
end
