module Core
  class BotLink < ApplicationRecord
    belongs_to :user, class_name: Core.user_class.to_s,
                      foreign_key: :user_id, inverse_of: :bot_links
  end
end
