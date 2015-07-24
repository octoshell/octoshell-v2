class Profile < ActiveRecord::Base
  belongs_to :user, class_name: User,
                    inverse_of: :profile

  def full_name
    [last_name, first_name, middle_name].join(" ")
  end

  def initials
    [first_name, middle_name].join(" ")
  end
end
