module Core
  class Project < ActiveRecord::Base

    belongs_to :kind, class_name: "Core::ProjectKind", foreign_key: :kind_id
    belongs_to :organization
    belongs_to :organization_department

    has_one :card, class_name: "Core::ProjectCard", dependent: :destroy,
                   inverse_of: :project, validate: true

    has_and_belongs_to_many :critical_technologies, join_table: "core_critical_technologies_per_projects"
    has_and_belongs_to_many :direction_of_sciences, join_table: "core_direction_of_sciences_per_projects"
    has_and_belongs_to_many :research_areas, join_table: "core_research_areas_per_projects"

    has_many :members, dependent: :destroy, inverse_of: :project
    has_many :users, through: :members, class_name: Core.user_class, inverse_of: :projects

    has_one :member_owner, -> { where(owner: true) }, class_name: Member
    has_one :owner, through: :member_owner,
                    class_name: Core.user_class,
                    source: :user,
                    inverse_of: :owned_projects

    has_many :requests, inverse_of: :project
    has_many :requested_clusters,
             -> { where(core_requests: {state: ['pending', 'active']})},
             through: :requests, source: :cluster

    has_many :accesses, inverse_of: :project
    # TODO: rename to available. typo.
    has_many :avaliable_clusters, -> { where(core_accesses: {state: 'opened'}) },
                                  through: :accesses, source: :cluster

    has_many :synchronization_logs, class_name: "Core::ClusterLog", inverse_of: :project

    has_many :sureties, inverse_of: :project

    has_many :invitations, class_name: "Core::ProjectInvitation"

    accepts_nested_attributes_for :card, :sureties

    validates :card, :title, presence: true, if: :project_is_not_closing?
    validates :direction_of_science_ids, :critical_technology_ids,
      :research_area_ids, length: { minimum: 1, message: I18n.t(".errors.choose_at_least") }, if: :project_is_not_closing?

    scope :finder, lambda { |q| where("lower(title) like :q", q: "%#{q.mb_chars.downcase}%").order("title asc") }

    after_create :engage_owner

    # def human_state_name
    #   state
    # end

    # def self.human_state_event_name name
    #   name.to_s
    # end

    def on_deactivate
      #!!! after_transition :active => [:cancelled, :blocked, :finished] do |project, transition|
      # Core::MailerWorker.perform_async(:project_suspended, project.id)
      accesses.where(state: :opened).map(&:close!)
      members.where(:project_access_state=>:allowed).map(&:suspend!)
      update(finished_at: Time.current) if finished?
      synchronize!
    end

    def on_activate
      #!!! after_transition [:closed, :finihed, :blocked, :cancelled, :suspended] => :active do |project, transition|
      accesses.where(state: :closed).map(&:reopen!)
      members.where(:project_access_state=>:suspended).map(&:activate!)
      ::Core::MailerWorker.perform_async(:project_activated, id)
      synchronize!
    end


    def invite_member(user_id)
      user = ::Core.user_class.find(user_id)
      users << user
      ::Core::MailerWorker.perform_async(:invitation_to_project, [user.id, self.id])
    rescue ::ActiveRecord::RecordNotUnique
      errors.add :member, I18n.t(".errors.user_is_already_in_members", email: user.full_name)
    rescue ::ActiveRecord::RecordNotFound
      errors.add :member, I18n.t(".errors.user_is_not_registered")
    end

    def drop_member(user_id)
      user = ::Core.user_class.find(user_id)
      users.delete(user)
    end

    def spare_clusters
      ::Core::Cluster.where.not(id: requested_clusters.pluck(:id) | avaliable_clusters.pluck(:id)).
              where(available_for_work: true)
    end

    # TODO: выяснить этот момент
    def involved_organizations
      members.where(project_access_state: :active).map(&:organization).uniq - organization
    end

    def synchronize!
      accesses.map { |a| AccessSynchronizer.perform_async(a.id) }
    end

    def to_s
      title
    end

    def as_json(options)
      { id: id, text: title }
    end

    def engage_owner
      member_owner.organization = organization
      member_owner.organization_department = organization_department
      member_owner.accept_invitation!
    end

    def project_is_not_closing?
      active? || pending?
    end

    include AASM
    include ::AASM_Additions
    aasm(:state, :column => :state) do
      state :pending, :initial => true   # свежесозданный проект
      state :cancelled # руководитель отменил работу над проектом
      state :active    # активен, по проекту есть работа
      state :suspended # приостановлен на некоторое время
      state :blocked   # заблокирован из-за нарушение правил
      state :closing   # legacy
      state :closed    # legacy
      state :finished  # проект завершён

      event :activate do
        transitions :from => :pending, :to => :active
        after do
          update(first_activation_at: Time.current)
          synchronize!
        end

      end

      event :cancel do
        transitions :from => [:pending, :active], :to => :cancelled
        after do
          on_deactivate if aasm(:state).from_state==:active
        end
      end

      event :block do
        transitions :from => :active, :to => :blocked
        after do
          on_deactivate
        end
      end

      event :unblock do
        transitions :from => :blocked, :to => :active
        after do
          on_activate
        end
      end

      event :suspend do
        transitions :from => :active, :to => :suspended
      end

      event :reactivate do
        transitions :from => :suspended, :to => :active
        after do
          on_activate
        end
      end

      event :finish do
        transitions :from => [ :pending, :active,
                    :suspended, :blocked,
                    :cancelled, :closing, :closed], :to => :finished
        after do
          on_deactivate if aasm(:state).from_state==:active
        end
      end

      event :resurrect do
        transitions :from => [:closed, :cancelled, :finished], :to => :active
        after do
          on_activate
        end
      end

    end
  end
end
