module Core
  module ApplicationHelper
    def mark_project_state(project)
      label_class = case project.state
                    when "active"
                      "success"
                    when "pending"
                      "info"
                    when "suspended"
                      "warning"
                    else
                      "danger"
                    end

      "<span class=\"label label-#{label_class} lg\">#{project.human_state_name}</span>".html_safe
    end

    def mark_ownership(project)
      "<i class=\"fa fa-flag\"></i>".html_safe if current_user == project.owner
    end

    def mark_member_state(project, member)
      label_class = case member.project_access_state
                    when "invited"
                      "info"
                    when "engaged"
                      "primary"
                    when "unsured"
                      "warning"
                    when "denied"
                      "danger"
                    when "suspended"
                      "danger"
                    else
                      "success"
                    end

      "<span class=\"label label-#{label_class} lg\">#{member.human_project_access_state_name}</span>".html_safe
    end

    def mark_request_state(request)
      label_class = case request.state
                    when "active"
                      "success"
                    when "pending"
                      "warning"
                    else
                      "danger"
                    end

      "<span class=\"label label-#{label_class} lg\">#{request.human_state_name}</span>".html_safe
    end
  end
end
