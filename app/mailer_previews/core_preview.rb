class CorePreview
  def invitation_to_project
    ::Core::Mailer.invitation_to_project(User.first.id, Core::Project.first.id)
  end

  def invitation_to_octoshell
    Core::Mailer.invitation_to_octoshell(Core::ProjectInvitation.first.id, 'ru')
  end

  def access_to_project_granted
    Core::Mailer.access_to_project_granted(Core::Member.first.id)
  end

  def access_to_project_denied
    Core::Mailer.access_to_project_denied(Core::Member.first.id)
  end

  def project_activated
    Core::Mailer.project_activated(Core::Member.find_by(project_access_state: :allowed).project.id)
  end

  def project_closed
    Core::Mailer.project_closed(Core::Member.find_by(project_access_state: :allowed).project.id)
  end

  def project_suspended
    Core::Mailer.project_suspended(Core::Member.find_by(project_access_state: :allowed).project.id)
  end

  def request_accepted
    Core::Mailer.request_accepted(Core::Request.first.id)
  end

  def request_rejected
    Core::Mailer.request_rejected(Core::Request.first.id)
  end

  def new_organization
    Core::Mailer.new_organization(Core::Organization.first.id)
  end

  def new_organization_department
    Core::Mailer.new_organization_department(Core::OrganizationDepartment.first.id)
  end

  def surety_accepted
    Core::Mailer.surety_accepted(Core::Surety.first.id)
  end

  def surety_rejected
    Core::Mailer.surety_rejected(Core::Surety.first.id)
  end

  def user_access_suspended
    Core::Mailer.surety_rejected(Core.user_class.first.id)
  end

  def user_access_activated
    Core::Mailer.surety_rejected(Core.user_class.first.id)
  end

  def resource_usage
    access = Core::Access.joins(:resource_controls).group('core_accesses.id')
                         .having('COUNT(core_resource_controls.id)>1').first
    Core::Mailer.resource_usage(access.resource_users.first.id, access.id)
  end

  def admin_resource_usage
    Core::Mailer.admin_resource_usage User.first.id
  end
end
