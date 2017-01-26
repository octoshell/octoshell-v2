module Jd
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    @@clusters = {"Lomonosov-1" => "http://graphit.parallel.ru:5000", "Lomonosov-2" => "http://graphit.parallel.ru:5001"}

    def get_available_projects()
      result = Hash.new { |hash, key| hash[key] = [] }

      projects_with_participation = current_user.projects.where.not(id: (current_user.owned_projects.pluck(:id) \
        | current_user.projects_with_invitation.pluck(:id))) # TODO ???

      current_user.owned_projects.each do |project|
        project.members.each do |member|
          result[project].push(member.login)
        end
      end

      projects_with_participation.each do |project|
        project.members.each do |member|
          if member.id == current_user.user_id
            result[project].push(member.login)
          end
        end
      end

      return result
    end
  end
end
