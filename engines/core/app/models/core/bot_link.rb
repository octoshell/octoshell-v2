# == Schema Information
#
# Table name: core_bot_links
#
#  id         :bigint(8)        not null, primary key
#  active     :boolean
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#
# Indexes
#
#  index_core_bot_links_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module Core
  class BotLink < ApplicationRecord
    belongs_to :user, class_name: Core.user_class.to_s,
                      foreign_key: :user_id, inverse_of: :bot_links
  end
end
