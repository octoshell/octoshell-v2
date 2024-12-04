class UsersController < ApplicationController
  def index
    @q = User.ransack(params[:q]) # Инициализация Ransack
    @users = @q.result(distinct: true) # Получение отфильтрованных пользователей

    @all_logins = {
      list: User.pluck(:login).reject { |login| login == "ALL" },
      options: User.group(:status).pluck(:status).map do |status| 
        [status, User.where(status: status).pluck(:login).reject { |login| login == "ALL" }]
      end
    }
  end
end