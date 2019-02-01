# == Schema Information
#
# Table name: profiles
#
#  id                    :integer          not null, primary key
#  user_id               :integer          not null
#  first_name            :string(255)
#  last_name             :string(255)
#  middle_name           :string(255)
#  about                 :text
#  receive_info_mails    :boolean          default(TRUE)
#  receive_special_mails :boolean          default(TRUE)
#

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
