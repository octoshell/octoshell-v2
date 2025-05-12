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

    has_many :project_critical_technologies, inverse_of: :project
    has_many :project_direction_of_sciences, inverse_of: :project
    has_many :project_research_areas, inverse_of: :project

    has_many :critical_technologies, through: :project_critical_technologies, inverse_of: :projects
    has_many :direction_of_sciences, through: :project_direction_of_sciences, inverse_of: :projects
    has_many :research_areas, through: :project_research_areas, inverse_of: :projects
    has_many :group_of_research_areas, through: :research_areas,
                                       class_name: GroupOfResearchArea.to_s,
                                       source: :group

    has_many :members, dependent: :destroy, inverse_of: :project
    has_many :users, through: :members, class_name: Core.user_class.to_s, inverse_of: :projects
    has_many :removed_members, dependent: :destroy, inverse_of: :project
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
    has_many :project_versions, inverse_of: :project

    has_many :job_notification_project_settings,
      class_name: 'Core::JobNotificationProjectSetting',
      foreign_key: 'core_project_id',
      dependent: :destroy

    accepts_nested_attributes_for :card, :sureties
    accepts_nested_attributes_for :project_critical_technologies,
                                  :project_direction_of_sciences,
                                  :project_research_areas,
                                  allow_destroy: true
    validates :card, :title, :organization, :kind, presence: true, if: :project_is_not_closing?
    validates :project_direction_of_sciences, :project_critical_technologies,
      :project_research_areas, length: { minimum: 1, message: I18n.t("errors.choose_at_least") }, if: :project_is_not_closing?

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

    scope :choose_to_hide, (lambda do |type, date_after, core_hours_gt, date_before, core_hours_lt|
      type = type.to_i
      return self if type != 1 && type != 2

      scope = if type == 2
        Perf::Job.project_id_in_period
      else
        Perf::Job.joins(:member)
                 .select('DISTINCT core_members.project_id as p_id')
      end
      if date_after.present?
        scope = scope.where("jobstat_jobs.submit_time >= '#{date_after}'")
      end
      if date_before.present?
        scope = scope.where("jobstat_jobs.submit_time <= '#{date_before}'")
      end
      if core_hours_gt.present?
        scope = scope.merge(Perf::Job.having_core_hours('>=', core_hours_gt))
      end
      if type == 1
        scope = scope.group('core_members.project_id')
      end
      if type == 2
        scope = scope.group(Perf::Job.new_coalesce_project)
      end
      if core_hours_lt.present?
        if !core_hours_gt.present? || core_hours_gt.to_i.zero?
          scope = scope.merge(Perf::Job.having_core_hours('>', core_hours_lt))
          scope = joins("LEFT JOIN (#{scope.to_sql})
                        AS j ON core_projects.id = j.p_id")
                        .where('j.p_id IS NULL')
          return scope
        else
          scope = scope.merge(Perf::Job.having_core_hours('<=', core_hours_lt))
        end
      end

      scope = joins("INNER JOIN (#{scope.to_sql})
                    AS j ON core_projects.id = j.p_id ")
      scope
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
      ActiveRecord::Base.transaction do
        member = members.create!(user_id: user_id)
        RemovedMember.where(member.attributes
                                  .slice('project_id', 'user_id', 'login'))
                     .map(&:destroy!)
      end
      ::Core::MailerWorker.perform_async(:invitation_to_project, [user.id, id])
    rescue ::ActiveRecord::RecordNotUnique
      errors.add :member, I18n.t("errors.user_is_already_in_members", email: user.full_name)
    rescue ::ActiveRecord::RecordNotFound
      errors.add :member, I18n.t("errors.user_is_not_registered")
    end

    def drop_member(user_id)
      member = members.find_by_user_id!(user_id)
      ActiveRecord::Base.transaction do
        RemovedMember.create!(member.attributes
                                    .slice('project_id', 'user_id', 'login'))
        member.destroy!
      end
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
      [:choose_to_hide, :hide_options_before, :hide_options_after]
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
        after do
          on_deactivate
        end

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

    def job_notification_settings(notification, user)
      project_setting = job_notification_project_settings.find_by(
        core_job_notification_id: notification.id,
        user: user
      )

      if project_setting.present?
        project_setting
      else
        user.job_notification_settings(notification)
      end
    end

  end
end
