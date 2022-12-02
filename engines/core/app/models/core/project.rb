# == Schema Information
#
# Table name: core_projects
#
#  id                         :integer          not null, primary key
#  estimated_finish_date      :datetime
#  finished_at                :datetime
#  first_activation_at        :datetime
#  state                      :string(255)
#  title                      :string(255)      not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  kind_id                    :integer
#  organization_department_id :integer
#  organization_id            :integer
#
# Indexes
#
#  index_core_projects_on_kind_id                     (kind_id)
#  index_core_projects_on_organization_department_id  (organization_department_id)
#  index_core_projects_on_organization_id             (organization_id)
#  index_core_projects_on_state                       (state)
#

module Core
  class Project < ApplicationRecord

    belongs_to :kind, class_name: "Core::ProjectKind", foreign_key: :kind_id
    belongs_to :organization
    belongs_to :organization_department

    has_one :card, class_name: "Core::ProjectCard", dependent: :destroy,
                   inverse_of: :project, validate: true

    has_and_belongs_to_many :critical_technologies, join_table: "core_critical_technologies_per_projects"
    has_and_belongs_to_many :direction_of_sciences, join_table: "core_direction_of_sciences_per_projects"
    has_and_belongs_to_many :research_areas, join_table: "core_research_areas_per_projects"
    has_many :group_of_research_areas, through: :research_areas,
                                       class_name: GroupOfResearchArea.to_s,
                                       source: :group

    has_many :members, dependent: :destroy, inverse_of: :project
    has_many :users, through: :members, class_name: Core.user_class.to_s, inverse_of: :projects

    has_one :member_owner, -> { where(owner: true) }, class_name: Member.to_s
    has_one :owner, through: :member_owner,
                    class_name: Core.user_class.to_s,
                    source: :user,
                    inverse_of: :owned_projects

    has_many :requests, inverse_of: :project
    has_many :requested_clusters,
             -> { where(core_requests: {state: ['pending', 'active']})},
             through: :requests, source: :cluster

    has_many :accesses, inverse_of: :project
    has_many :available_clusters, -> { where(core_accesses: {state: 'opened'}) },
                                  through: :accesses, source: :cluster

    has_many :synchronization_logs, class_name: "Core::ClusterLog", inverse_of: :project

    has_many :sureties, inverse_of: :project

    has_many :invitations, class_name: "Core::ProjectInvitation"


    accepts_nested_attributes_for :card, :sureties

    validates :card, :title, :organization, :kind, presence: true, if: :project_is_not_closing?
    validates :direction_of_science_ids, :critical_technology_ids,
      :research_area_ids, length: { minimum: 1, message: I18n.t("errors.choose_at_least") }, if: :project_is_not_closing?
    validate do
      errors.add(:organization_department, :dif) if organization_department && organization_department.organization != organization
    end

    scope :finder, lambda { |q| where("lower(title) like :q", q: "%#{q.mb_chars.downcase}%").order("title asc") }

    def members_for_new_surety
      members.joins(:user).where(project_access_state: :engaged,
                                  users: { access_state: 'active'})
    end

    after_create :engage_owner

    # def human_state_name
    #   state
    # end

    # def self.human_state_event_name name
    #   name.to_s
    # end

    scope :hide_with_zero_impact, (lambda do |project|
      joins("INNER JOIN 
        (SELECT project_id FROM core_members INNER JOIN jobstat_jobs 
        ON core_members.login = jobstat_jobs.login) AS jobs
        ON id = jobs.project_id")
    end)

    scope :hide_with_zero_impact_considering_deleted_members, (lambda do |project|
      joins("INNER JOIN (SELECT object FROM versions INNER JOIN jobstat_jobs ON 
        versions.object LIKE CONCAT('%login: ', jobstat_jobs.login, '%')) AS objects
        ON objects.object LIKE CONCAT('%project_id: ', core_projects.id, '%')")
    end)

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
      accesses.where(state: :closed).map{|a| a.reopen!; a.save}
      members.where(:project_access_state=>:suspended).map(&:activate!)
      ::Core::MailerWorker.perform_async(:project_activated, id)
      synchronize!
    end


    def invite_member(user_id)
      user = ::Core.user_class.find(user_id)
      users << user
      ::Core::MailerWorker.perform_async(:invitation_to_project, [user.id, self.id])
    rescue ::ActiveRecord::RecordNotUnique
      errors.add :member, I18n.t("errors.user_is_already_in_members", email: user.full_name)
    rescue ::ActiveRecord::RecordNotFound
      errors.add :member, I18n.t("errors.user_is_not_registered")
    end

    def drop_member(user_id)
      user = ::Core.user_class.find(user_id)
      users.destroy(user)
    end

    def spare_clusters
      ::Core::Cluster.where.not(id: requested_clusters.pluck(:id) | available_clusters.pluck(:id)).
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

    def self.ransackable_scopes_skip_sanitize_args
      ransackable_scopes
    end

    def self.ransackable_scopes(_auth_object = nil)
      [:hide_with_zero_impact, :hide_with_zero_impact_considering_deleted_members]
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
          synchronize!
        end

        before do
          self.first_activation_at = Time.current
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

    def self.can_not_be_automerged(department)
      joins(:members)
        .joins("INNER JOIN core_employments As e ON
          e.organization_id = #{department.organization_id} AND
          core_members.user_id = e.user_id AND
          e.organization_department_id = #{department.id}")
        .where('core_projects.organization_department_id IS NULL OR core_projects.organization_department_id != e.organization_department_id ')
        .where(core_members: {organization_id: department.organization_id, owner: true})
        .distinct('core_projects.id')
    end

    def self.can_not_be_automerged?(department)
      can_not_be_automerged(department).exists?
    end
  end
end
