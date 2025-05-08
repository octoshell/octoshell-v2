module Core
  class TelegramJobNotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3

    def perform(user_id, params)
      user = User.find(user_id)
      bot_link = user.bot_links.find_by_active(true)
      return unless bot_link

      Core::BotLinksApiHelper.notify('/send_digest', params.merge(token: bot_link.token, email: user.email))
    rescue => e
      Rails.logger.error "TelegramNotificationWorker error for user #{user_id}: #{e.message}"
      raise e
    end
  end
end
