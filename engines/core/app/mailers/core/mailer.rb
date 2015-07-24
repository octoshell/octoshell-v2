module Core
  class Mailer < ActionMailer::Base
    def invitation_to_project(user_id, project_id)
      @user = Core.user_class.find(user_id)
      @project = Core::Project.find(project_id)
      mail to: @user.email, subject: t(".subject", title: @project.title)
    end

    def invitation_to_octoshell(invitation_id)
      @invitation = Core::ProjectInvitation.find(invitation_id)
      mail to: @invitation.user_email, subject: t(".subject", title: @invitation.project.title)
    end

    def access_to_project_granted(member_id)
      @user = Core::Member.find(member_id)
      mail to: @user.email, subject: t(".subject", title: @user.project.title)
    end

    def access_to_project_denied(member_id)
      @user = Core::Member.find(member_id)
      mail to: @user.email, subject: t(".subject", title: @user.project.title)
    end

    def project_activated(project_id)
      @project = Core::Project.find(project_id)
      member_emails = @project.members.with_project_access_state(:allowed).preload(:user).map(&:email)
      mail to: member_emails, subject: t(".subject", title: @project.title)
    end

    def project_closed(project_id)
      @project = Core::Project.find(project_id)
      member_emails = @project.members.with_project_access_state(:allowed).preload(:user).map(&:email)
      mail to: member_emails, subject: t(".subject", title: @project.title)
    end

    def project_suspended(project_id)
      @project = Core::Project.find(project_id)
      member_emails = @project.members.with_project_access_state(:allowed).preload(:user).map(&:email)
      mail to: member_emails, subject: t(".subject", title: @project.title)
    end

    def request_accepted(request_id)
      @request = Core::Request.find(request_id)
      @user = @request.project.owner
      mail to: @user.email, subject: t(".subject", number: @request.id)
    end

    def request_rejected(request_id)
      @request = Core::Request.find(request_id)
      @user = @request.project.owner
      mail to: @user.email, subject: t(".subject", number: @request.id)
    end

    def new_organization(organization_id)
      @organization = Core::Organization.find(organization_id)
      admin_emails = Core.user_class.superadmins.map(&:email)
      mail to: admin_emails, subject: t(".subject")
    end

    def new_organization_department(department_id)
      @department = Core::OrganizationDepartment.find(department_id)
      admin_emails = Core.user_class.superadmins.map(&:email)
      mail to: admin_emails, subject: t(".subject", org_title: @department.organization.short_name)
    end

    def surety_confirmed(surety_id)
      @surety = Core::Surety.find(surety_id)
      admin_emails = Core.user_class.superadmins.map(&:email)
      mail to: admin_emails, subject: t(".subject", number: @surety.id)
    end

    def surety_accepted(surety_id)
      @surety = Core::Surety.find(surety_id)
      @user = @surety.author
      mail to: @user.email, subject: t(".subject", number: @surety.id)
    end

    def surety_rejected(surety_id)
      @surety = Core::Surety.find(surety_id)
      @user = @surety.author
      mail to: @user.email, subject: t(".subject", number: @surety.id)
    end

    def user_access_suspended(user_id)
      @user = Core.user_class.find(user_id)
      mail to: @user.email, subject: t(".subject")
    end

    def user_access_activated(user_id)
      @user = Core.user_class.find(user_id)
      mail to: @user.email, subject: t(".subject")
    end
  end
end
