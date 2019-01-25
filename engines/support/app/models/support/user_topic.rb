# == Schema Information
#
# Table name: support_user_topics
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  topic_id   :integer
#  required   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Support
  class UserTopic < ActiveRecord::Base
    belongs_to :topic
    belongs_to :user
    validates :topic, :user, presence: true
  end
end
