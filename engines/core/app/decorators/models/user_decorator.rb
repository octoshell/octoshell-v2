Core.user_class.class_eval do
  has_many :credentials, class_name: "::Core::Credential",
    foreign_key: :user_id, inverse_of: :user, dependent: :destroy
  has_many :accounts, class_name: "::Core::Member",
    foreign_key: :user_id, inverse_of: :user, dependent: :destroy
  has_many :projects, through: :accounts,
    class_name: "::Core::Project",
    source: :project,
    inverse_of: :users, dependent: :destroy

  has_many :account_owners, ->{ where(owner: true) },
    class_name: "::Core::Member",
    foreign_key: :user_id
  has_many :owned_projects, through: :account_owners,
    class_name: "::Core::Project",
    source: :project,
    inverse_of: :owner

  def requests
    Core::Request.joins(project: :owner).where('core_members.user_id = ?', id)
  end

  has_many :invitational_account, ->{ where(project_access_state: "invited") },
    class_name: "::Core::Member",
    foreign_key: :user_id
  has_many :projects_with_invitation, ->{ where.not(state: ["cancelled", "closed"]) },
    through: :invitational_account, class_name: "::Core::Project",
    source: :project

  has_many :active_accounts, ->{ where(project_access_state: "allowed") },
    class_name: "::Core::Member",
    foreign_key: :user_id
  has_many :available_projects, ->{ where(state: "active") },
    through: :active_accounts, class_name: "::Core::Project",
    source: :project

  has_many :employments,
    class_name: "::Core::Employment",
    foreign_key: :user_id, dependent: :destroy
  has_many :organizations,
    class_name: "::Core::Organization",
    through: :employments,
    inverse_of: :users
  has_many :organization_departments, through: :employments

  has_many :active_employments, -> { where(state: 'active') },
    class_name: "::Core::Employment",
    foreign_key: :user_id, dependent: :destroy
  has_many :active_organizations,
    class_name: "::Core::Organization",
    through: :active_employments,
    source: :organization
  has_many :active_organization_departments,
           class_name: "::Core::OrganizationDepartment",
           through: :active_employments,
           source: :organization_department


  has_one :primary_employment, ->{ where(primary: true) },
    class_name: "::Core::Employment",
    foreign_key: :user_id
  has_one :primary_organization, through: :primary_employment,
    class_name: "::Core::Organization",
    source: :organization,
    inverse_of: :users

  has_many :surety_members, class_name: "::Core::SuretyMember", dependent: :destroy
  has_many :sureties, through: :surety_members, class_name: "::Core::Surety"

  has_many :authored_sureties, class_name: "::Core::Surety", foreign_key: :author_id, inverse_of: :author

  scope :with_active_projects, -> { joins(accounts: :project).where(core_projects: {state: "active"}, core_members: {project_access_state: "allowed"}).distinct }


  after_create :check_project_invitations

  include AASM
  include ::AASM_Additions
  aasm(:access_state, :column => :access_state) do
    state :active, :initial => true
    state :closed

    event :block do
      transitions :from => :active, :to => :closed, :after => :suspend_all_accounts
    end

    event :reactivate do
      transitions :from => :closed, :to => :active, :after => :activate_suspended_accounts
    end

    #inside_transition on: :block, &:suspend_all_accounts
    #inside_transition on: :reactivate, &:activate_suspended_accounts
  end

  def suspend_all_accounts
    accounts.where(:project_access_state=>:allowed).map(&:suspend!)
    available_projects.each(&:synchronize!)
  end

  def activate_suspended_accounts
    accounts.where(:project_access_state=>:suspended).map(&:activate!)
    available_projects.each(&:synchronize!)
  end

  def prepared_to_join_projects?
    b=credentials.where(:state => :active).any?
    c=employments.any?
    a=(self.aasm(:access_state).current_state == :active)
    a && b && c
  end

  def self.cluster_access_state_present(_arg = nil)
    User.joins([:employments, :credentials, { accounts: :project }])
        .where(core_members: { project_access_state: 'allowed' })
        .where(core_projects: { state: 'active' })
        .where(access_state: :active)
        .distinct

  end

  def human_access_state_name
    human_state_name
  end

  def access_state_name
    access_state
  end

  def self.human_access_state_names
    Hash[User.aasm(:access_state).states.map { |s| [human_state_name(s.name), s.name] } ]
  end

  def check_project_invitations
    invitations = Core::ProjectInvitation.where(user_email: email)
    invitations.each do |invitation|
      accounts.create!(project_id: invitation.project_id)
      invitation.destroy!
    end
  end

  def checked_active_organization_departments(project = nil)
    rel1 = active_organization_departments
           .joins(:organization)
           .where(checked: true)
           .where("core_organizations.checked = 't'")
    return rel1 unless project
    rel2 = Core::OrganizationDepartment
           .where(id: project.organization_department_id)
    rel1.union rel2
  end

  def checked_active_organization_departments_to_hash(organizations, project = nil)
    rel = checked_active_organization_departments(project)
    hash = rel.to_a.group_by(&:organization_id)
    hash.each do |key, value|
      hash[key] = value.map { |i| i.as_json(:nothing) }
    end
    organizations.each do |o|
      hash[o.id] = [{}] unless hash[o.id]
    end
    hash
  end

  def checked_active_organizations(project = :no_project)
    rel1 = active_organizations
           .where(checked: true)
    return rel1 if project == :no_project
    rel2 = Core::Organization
           .where(id: project.organization_id)
    rel1.union rel2
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[cluster_access_state_present]
  end

end if Core.user_class
