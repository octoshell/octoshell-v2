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

      authed_user = nil
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
                authed_user = user
              end
            end
          end
        end
      end

      res = Hash.new
      res["user"] = authed_user
      if has_active_token
        res["status"] = 0
      elsif has_inactive_token
        res["status"] = 1
      elsif has_email
        res["status"] = 2
      else
        res["status"] = 3
      end
      return res
    end

    def self.user_projects(params)
      auth_info = self.auth(params)
      if auth_info["status"] == 0
        projects = Array.new

        user = auth_info["user"]
        members = Core::Member.where(user_id: user.id)
        members.each do |member|
          proj = Hash.new

          proj["title"] = Core::Project.where(id: member.project_id)[0].title
          proj["login"] = member.login
          proj["owner"] = member.owner

          projects << proj
        end

        res = Hash.new
        res["status"] = "ok"
        res["projects"] = projects
        return res
      else
        return Hash["status", "fail"]
      end
    end
  end
end
