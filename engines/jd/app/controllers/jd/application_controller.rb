module Jd
  class ApplicationController < ActionController::Base
    include AuthMayMay
    layout "layouts/application"

    protect_from_forgery with: :exception


    @@systems = Rails.configuration.jd_systems

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
          if member.user_id == user.id
            result[project].push(member.login)
          end
        end
      end

      return result
    end
  end
end
