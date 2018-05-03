module Core
  class Member < ActiveRecord::Base

    belongs_to :user, class_name: Core.user_class, foreign_key: :user_id, inverse_of: :accounts
    belongs_to :project, inverse_of: :members
    belongs_to :organization
    belongs_to :organization_department
    delegate :full_name, :email, :credentials, :sured?, to: :user

    include AASM
    include ::AASM_Additions
    aasm(:project_access_state, :column => :project_access_state) do
      state :invited, :initial => true   # приглашён, не подтвердил участие
      state :engaged   # принял приглашение (заполнил организации)
      state :unsured   # упомянут в ещё не активированном поручительстве
      state :allowed   # поручительство подписано и одобрено администрацией
      state :denied
      state :suspended # участие приостановлено, т.к. проект неактивен

      event :accept_invitation do
        transitions :from => :invited, :to => :engaged
      end

      event :append_to_surety do
        transitions :from => :engaged, :to => :unsured
      end

      event :substract_from_surety do
        transitions :from => [:allowed, :unsured], :to => :engaged
      end

      event :activate do
        transitions :from => [:unsured, :suspended], :to => :allowed

        after do
          if aasm(:project_access_state).from_state==:unsured
            ::Core::MailerWorker.perform_async(:access_to_project_granted, id)
            if project.pending? && project.accesses.where(state: :opened).any?
              project.activate!
            end
          elsif aasm(:project_access_state).from_state == :suspended
            ::Core::MailerWorker.perform_async(:access_to_project_granted, id)
          end
        end
      end

      event :deny do
        transitions :from => :allowed, :to => :denied

        after do
          ::Core::MailerWorker.perform_async(:access_to_project_denied, id)
        end
      end

      event :allow do
        transitions :from => :denied, :to => :allowed

        after do
          ::Core::MailerWorker.perform_async(:access_to_project_granted, id)
        end
      end

      event :suspend do
        transitions :from => :allowed, :to => :suspended
      end
    end

    def human_project_access_state_name st=nil
      if st.nil?
        project_access_state.to_s
      else
        st
      end
    end

    def create_or_update
      assign_login if new_record?
      super
    end

    def toggle_project_access_state!
      if allowed?
        deny!
      elsif denied?
        allow!
      end
    end

    def has_access_to_clusters?
      project.active? && user.prepared_to_join_projects? && allowed?
    end

    def assign_login
      new_login = email.delete(".+_-")[/^(.+)@/, 1].downcase
      self.login = "#{new_login[0,24]}_#{project.id}"
    end

    def self.department_members(department)
      where(organization_id: department.organization_id)
        .where("core_members.organization_department_id is NULL
          OR core_members.organization_department_id = #{department.id}")
        .joins("INNER JOIN core_employments AS u_e ON core_members.user_id = u_e.user_id AND
          u_e.organization_department_id = #{department.id}")
        .joins("LEFT JOIN core_employments As e ON
          e.organization_id = #{department.organization_id} AND
          core_members.user_id = e.user_id")
        .group('core_members.id')
    end

    def self.can_be_automerged(department)
      department_members(department).having("COUNT( DISTINCT COALESCE(e.organization_department_id,-1)) = 1")
    end

    def self.can_not_be_automerged(department)
      department_members(department).having("Count( DISTINCT COALESCE(e.organization_department_id,-1)) > 1")
    end

    def self.can_not_be_automerged?(department)
      can_not_be_automerged(department).exists?
    end

  end
end
