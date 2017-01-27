module Jd
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    rescue_from MayMay::Unauthorized, with: :not_authorized

    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
    end

    @@systems = {"Lomonosov-1" => "http://graphit.parallel.ru:5000", "Lomonosov-2" => "http://graphit.parallel.ru:5001"}

    def get_available_projects(user)
      # get hash with projects and logins for user
      # include all logins from owned projects and
      # only personal logins for other projects

      result = Hash.new { |hash, key| hash[key] = [] }

      projects_with_participation = user.projects.where.not(id: (user.owned_projects.pluck(:id) \
        | user.projects_with_invitation.pluck(:id))) # TODO ???

      user.owned_projects.each do |project|
        project.members.each do |member|
          result[project].push(member.login)
        end
      end

      projects_with_participation.each do |project|
        project.members.each do |member|
          if member.id == user.user_id
            result[project].push(member.login)
          end
        end
      end

      return result
    end
  end
end
