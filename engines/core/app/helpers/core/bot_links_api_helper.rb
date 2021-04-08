module Core
  module BotLinksApiHelper
    def self.load_bot_links
      BotLink.all
    end

    def self.notify(subpath, params)
      require 'net/http'
      require 'json'
      host = 'localhost' # HOST OF OCTOSHELL BOT APP
      port = '8080' # PORT OF OCTOSHELL BOT APP

      path = "/notify" + subpath
      body = params.to_json

      request = Net::HTTP::Post.new(path, 'Content-Type' => 'application/json')
      request.body = body
      begin
        Net::HTTP.new(host, port).start { |http| http.request(request) }
      rescue ::Errno::ECONNREFUSED => e
        Rails.logger.error "Failed to use BotLinksApiHelper: #{e}"
      end
      nil
    end

    def self.notify_about_ticket(ticket, event)
      params = []

      users = ticket.subscribers
      users.each do |user|
        bot_link = user.bot_links.where(active: true).first

        user_info = {}
        user_info['token'] = bot_link.token unless bot_link.nil?
        user_info['subject'] = ticket.subject
        user_info['email'] = user.email
        user_info['event'] = event

        params << user_info
      end

      self.notify('/ticket', params)
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

    def self.topics(params)
      auth_info = self.auth(params)
      if auth_info["status"] == 0
        topics = Array.new

        Support::Topic.all.each do |topic|
          data = Hash.new
          data["name_ru"] = topic.name_ru
          data["name_en"] = topic.name_en
          topics << data
        end

        res = Hash.new
        res["status"] = "ok"
        res["topics"] = topics
        return res
      else
        return Hash["status", "fail"]
      end
    end

    def self.clusters(params)
      auth_info = self.auth(params)
      if auth_info["status"] == 0
        clusters = Array.new

        Core::Cluster.all.each do |cluster|
          data = Hash.new
          data["name_ru"] = cluster.name_ru
          data["name_en"] = cluster.name_en
          clusters << data
        end

        res = Hash.new
        res["status"] = "ok"
        res["clusters"] = clusters
        return res
      else
        return Hash["status", "fail"]
      end
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

    def self.user_tickets(params)
      auth_info = self.auth(params)
      if auth_info["status"] == 0
        tickets = Array.new

        user = auth_info["user"]
        Support::Ticket.where(reporter_id: user.id).each do |ticket|
          tickets << self.fill_ticket_data(ticket, "reporter")
        end
        Support::Ticket.where(responsible_id: user.id).each do |ticket|
          tickets << self.fill_ticket_data(ticket, "responsible")
        end

        res = Hash.new
        res["status"] = "ok"
        res["tickets"] = tickets
        return res
      else
        return Hash["status", "fail"]
      end
    end

    def self.user_jobs(params)
      auth_info = self.auth(params)
      if auth_info["status"] == 0
        user = auth_info["user"]
        logins = Core::Member.where(user_id: user.id).map(&:login)
        jobs = Jobstat::Job.where(login: logins).order(:drms_job_id).map(&:attributes)

        res = Hash.new
        res["status"] = "ok"
        res["jobs"] = jobs
        return res
      else
        return Hash["status", "fail"]
      end
    end

    def self.fill_ticket_data(ticket, who)
      data = Hash.new

      topic = Support::Topic.where(id: ticket.topic_id).take
      unless topic.nil?
        data["topic_name_ru"] = topic.name_ru
        data["topic_name_en"] = topic.name_en
      end

      project = Core::Project.where(id: ticket.project_id).take
      unless project.nil?
        data["project_title"] = project.title
      end

      cluster = Core::Cluster.where(id: ticket.cluster_id).take
      unless cluster.nil?
        data["cluster_name_ru"] = cluster.name_ru
        data["cluster_name_en"] = cluster.name_en
      end

      data["who"] = who
      data["subject"] = ticket.subject
      data["message"] = ticket.message
      data["state"] = ticket.state

      return data
    end

    def self.create_ticket(params)
      auth_info = self.auth(params)
      if auth_info["status"] == 0
        # find project
        if Core::Project.exists?(title: params["project"])
          project = Core::Project.where(title: params["project"]).take
        else
          return Hash["status", "no such project"]
        end

        # find topic
        if Support::Topic.exists?(name_ru: params["topic"])
          topic = Support::Topic.where(name_ru: params["topic"]).take
        elsif Support::Topic.exists?(name_en: params["topic"])
          topic = Support::Topic.where(name_en: params["topic"]).take
        else
          return Hash["status", "no such topic"]
        end

        # find cluster
        if Core::Cluster.exists?(name_ru: params["cluster"])
          cluster = Core::Cluster.where(name_ru: params["cluster"]).take
        elsif Core::Cluster.exists?(name_en: params["cluster"])
          cluster = Core::Cluster.where(name_en: params["cluster"]).take
        else
          return Hash["status", "no such cluster"]
        end

        subject = params["subject"]
        message = params["message"]
        user = auth_info["user"]

        # create ticket
        Support::Ticket.create(topic: topic, project: project,
          cluster: cluster, reporter: user, subject: subject, message: message,
          state: :pending)

        return Hash["status", "ok"]
      else
        return Hash["status", "fail"]
      end
    end
  end
end
