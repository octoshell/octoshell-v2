# desc "Explaining what the task does"
namespace :face do
  task init_menu: :environment do
    ActiveRecord::Base.transaction do
      Face::MyMenu.init_menu
    end
  end
end
