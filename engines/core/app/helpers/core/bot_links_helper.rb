require 'securerandom'

module Core
  module BotLinksHelper
    def self.generate_unique_token
      prev_tokens = BotLink.select(:token)
      loop do
        new_token = SecureRandom.hex(5)
        return new_token unless prev_tokens.include? new_token
      end
    end

    def self.disactive_tokens(user_id)
      bot_links = BotLink.where(user_id: user_id).where(active: true)
      bot_links.each do |bot_link|
        bot_link.active = false
        bot_link.save
      end
    end
  end
end
