module Jobstat
  class JobMailFilter < ActiveRecord::Base
    # condition

    belongs_to :user

    def self.filters_for_user user
      id = user.is_a?(Integer) ? user : user.id
      where(user_id: id).map{|e| e.condition}
    end

    def self.add_mail_filter user,condition
      id = user.is_a?(Integer) ? user : user.id
      f = JobMailFilter.new(user_id: id, condition: condition)
      f.save
    end

    def self.del_mail_filter user,condition
      id = user.is_a?(Integer) ? user : user.id
      f = where(user_id: id, condition: condition)
      f.destroy_all
    end
  end
end
