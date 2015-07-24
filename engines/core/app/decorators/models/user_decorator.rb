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

  has_many :invitational_account, ->{ where(project_access_state: "invited") },
    class_name: "::Core::Member",
    foreign_key: :user_id
  has_many :projects_with_invitation, ->{ without_state(["cancelled", "closed"]) },
    through: :invitational_account, class_name: "::Core::Project",
    source: :project

  has_many :active_accounts, ->{ where(project_access_state: "allowed") },
    class_name: "::Core::Member",
    foreign_key: :user_id
  has_many :available_projects, ->{ with_state("active") },
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

  state_machine :access_state, initial: :active do
    state :active
    state :closed

    event :block do
      transition active: :closed
    end

    event :reactivate do
      transition closed: :active
    end

    inside_transition on: :block, &:suspend_all_accounts
    inside_transition on: :reactivate, &:activate_suspended_accounts
  end

  def suspend_all_accounts
    accounts.with_project_access_state(:allowed).map(&:suspend!)
    available_projects.each(&:synchronize!)
  end

  def activate_suspended_accounts
    accounts.with_project_access_state(:suspended).map(&:activate!)
    available_projects.each(&:synchronize!)
  end

  def prepared_to_join_projects?
    active? && credentials.with_state(:active).any? &&
      employments.any?
  end

  def self.human_access_state_names
    Hash[User.state_machines[:access_state].states.map {|s| [s.human_name, s.name] }]
  end

  def check_project_invitations
    invitations = Core::ProjectInvitation.where(user_email: email)
    invitations.each do |invitation|
      accounts.create!(project_id: invitation.project_id)
      invitation.destroy!
    end
  end
end if Core.user_class
