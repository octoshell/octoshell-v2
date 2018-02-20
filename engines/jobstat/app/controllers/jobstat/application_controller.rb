module Jobstat
  class ApplicationController < ActionController::Base
    layout "layouts/application"

    def not_authenticated
      redirect_to main_app.root_path, alert: t("flash.not_logged_in")
    end

    def not_authorized
      redirect_to main_app.root_path, alert: t("flash.not_authorized")
    end

    def get_owned_projects(user)
      # get hash with projects and logins for user
      # include all logins from owned projects

      result = Hash.new {|hash, key| hash[key] = []}

      user.owned_projects.each do |project|
        project.members.each do |member|
          result[project].push(member.login)
        end
      end

      result
    end

    def get_involved_projects(user)
      # get hash with projects and logins for user
      # include all personal logins for projects, where user is involved

      result = Hash.new {|hash, key| hash[key] = []}

      projects_with_participation = user.projects.where.not(id: (user.owned_projects.pluck(:id) \
         | user.projects_with_invitation.pluck(:id))) # TODO ???

      projects_with_participation.each do |project|
        project.members.each do |member|
          if member.user_id == user.id
            result[project].push(member.login)
          end
        end
      end

      result
    end

    def fill_owned_logins
      @owned_projects = get_owned_projects(current_user)

      @owned_logins = @owned_projects.map {|_, value| value}.uniq
      @owned_logins = ["vurdizm"]

    end

    def fill_involved_logins
      get_involved_projects = get_involved_projects(current_user)
      @involved_logins = get_involved_projects.map {|_, value| value}.uniq
      @involved_logins = ["vurdizm"]
    end
  end
end
