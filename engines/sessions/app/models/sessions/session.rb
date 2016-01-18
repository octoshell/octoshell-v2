# Перерегистрация
# В процессе перерегистрации пользователи присылают на оценку отчёты Reports,
# а также заполняют опросники Surveys, создавая UserSurveys.

module Sessions
  class Session < ActiveRecord::Base
    belongs_to :personal_survey, class_name: "Survey"
    belongs_to :projects_survey, class_name: "Survey"
    belongs_to :counters_survey, class_name: "Survey"

    has_many :reports, dependent: :destroy

    has_many :projects_in_sessions
    has_many :involved_projects, class_name: "Core::Project", source: :project, through: :projects_in_sessions

    has_many :surveys, dependent: :destroy
    has_many :user_surveys, dependent: :destroy
    has_many :users, class_name: "::User", through: :user_surveys

    has_many :stats

    validates :description, :receiving_to, presence: true

    state_machine :state, initial: :pending do
      state :pending
      state :active
      state :ended

      event :start do
        transition :pending => :active
      end

      event :stop do
        transition :active => :ended
      end

      inside_transition :on => :start do |session|
        session.enqueue_session_start
        session.touch :started_at
      end

      inside_transition :on => :stop do |session|
        session.enqueue_session_validation
        session.touch :ended_at
      end
    end

    def self.current
      with_state(:active).first
    end

    def survey_fields
      SurveyField.where(survey_id: survey_ids)
    end

    def enqueue_session_start
      Sessions::StarterWorker.perform_async(id)
    end

    def enqueue_session_validation
      Sessions::ValidatorWorker.perform_async(id)
    end

    def not_sent?
      pending? || filling?
    end

    def to_s
      description
    end

    def create_reports_and_users_surveys
      involved_projects.each do |project|
        create_report_and_surveys_for(project)
      end
      create_personal_user_surveys
    end

    def create_personal_user_surveys
      personal_survey = surveys.find { |s| s.personal? }
      User.with_active_projects.merge(involved_projects).find_each do |user|
        user.surveys.create!(session: self, survey: personal_survey)
      end
    end

    def create_report_and_surveys_for(project)
      project.reports.create!(session: self, author: project.owner)
      surveys_per_project = surveys.reject { |s| s.personal? }
      surveys_per_project.each do |survey|
        if survey.only_for_project_owners?
          project.owner.surveys.create!(session: self, survey: survey, project: project)
        else
          project.members.with_project_access_state(:allowed).each do |member|
            member.user.surveys.create!(session: self, survey: survey, project: project)
          end
        end
      end
    end

    def moderate_included_projects(selected_project_ids)
      exclude_projects_from_session(selected_project_ids)
      update(involved_project_ids: selected_project_ids)
    end

    def exclude_projects_from_session(selected_project_ids)
      excluded_project_ids = involved_project_ids.select do |project_id|
        !selected_project_ids.include? project_id
      end
      excluded_projects = ProjectsInSession.where(session: self).where(project_id: excluded_project_ids)
      excluded_projects.each { |ip| clear_report_and_surveys_for(ip.project) } if self.active?
      excluded_projects.destroy_all
    end

    def clear_report_and_surveys_for(project)
      project.reports.where(session: self).destroy_all
      project.members.with_project_access_state(:allowed).each do |member|
        member.user.surveys.where(session: self, project: project).destroy_all
      end
      # TODO Mailer: project is excluded from session.
      # Sessions::MailerWorker
    end

    def validate_reports_and_surveys
      reports.with_state(:assessed).select(&:failed?).map(&:close_project!)
      reports.with_state([:pending, :accepted, :rejected]).map(&:postdate!)
      notify_experts_about_submitted_reports if reports.with_state(:submitted).any?
      notify_exports_about_assessing_reports if reports.with_state(:assessing).any?

      user_surveys.with_state([:pending, :filling]).map(&:postdate!)
    end

    def notify_experts_about_submitted_reports
      Sessions::MailerWorker.perform_async(:notify_exerts_about_submitted_reports, id)
    end

    def notify_exports_about_assessing_reports
      Sessions.user_class.experts.each do |expert|
        if expert.assesing_reports.any?
          Sessions::MailerWorker.perform_async(:notify_expert_about_assessing_reports, expert.id)
        end
      end
    end
  end
end
