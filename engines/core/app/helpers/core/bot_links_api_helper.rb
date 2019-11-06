module Core
  module BotLinksApiHelper
    def self.load_bot_links
      BotLink.all
    end

    def self.auth(params)
      email = params[:email]
      token = params[:token]

      # is there a user with given email and token?
      has_email = false
      has_inactive_token = false
      has_active_token = false

      BotLink.all.each do |bot_link|
        user_id = bot_link.user_id
        if user_id
          user = User.find(user_id)

          if user.email == email
            has_email = true

            if bot_link.token == token
              has_inactive_token = true

              if bot_link.active == true
                has_active_token = true
              end
            end
          end
        end
      end

      if has_active_token
        return 0
      elsif has_inactive_token
        return 1
      elsif has_email
        return 2
      else
        return 3
      end
    end
  end
end
