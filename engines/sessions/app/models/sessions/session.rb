# == Schema Information
#
# Table name: sessions_sessions
#
#  id             :integer          not null, primary key
#  state          :string(255)
#  description_ru :text
#  motivation_ru  :text
#  started_at     :datetime
#  ended_at       :datetime
#  receiving_to   :datetime
#  description_en :text
#  motivation_en  :text
#

# Перерегистрация
# В процессе перерегистрации пользователи присылают на оценку отчёты Reports,
# а также заполняют опросники Surveys, создавая UserSurveys.

module Sessions
  class Session < ApplicationRecord

    include SessionProject



    translates :description, :motivation

    belongs_to :personal_survey, class_name: "Survey"
    belongs_to :projects_survey, class_name: "Survey"
    belongs_to :counters_survey, class_name: "Survey"

    has_many :reports, dependent: :destroy

    # has_many :projects_in_sessions
    # has_many :involved_projects, class_name: "Core::Project", source: :project, through: :projects_in_sessions

    has_many :surveys, dependent: :destroy
    has_many :user_surveys, dependent: :destroy
    has_many :users, class_name: "::User", through: :user_surveys

    has_many :stats

    validates :receiving_to, presence: true
    validates_translated :description, presence: true

    include ::AASM
    include ::AASM_Additions
    aasm(:state, :column => :state) do
      state :pending, :initial => true
      state :active
      state :ended

      event :start do
        transitions :from => :pending, :to => :active
        after do
          enqueue_session_start
          touch :started_at
        end
      end

      event :stop do
        transitions :from => :active, :to => :ended
        after do
          enqueue_session_validation
          touch :ended_at
        end
      end

    end

    def self.current
      where(state: :active).first || last
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
      pending? || filling? || postfilling?
    end

    def to_s
      description
    end

    def create_reports_and_users_surveys
      if Sessions.link?(:project)
        involved_projects.each do |project|
          create_report_and_surveys_for(project)
        end
      end
      create_personal_user_surveys
    end

    def create_personal_user_surveys
      personal_surveys = surveys.where(only_for_project_owners: false)
      personal_surveys.each do |personal_survey|
        User.with_active_projects.merge(involved_projects).find_each do |user|
          user.surveys.create!(session: self, survey: personal_survey)
        end
      end
    end

    # def create_report_and_surveys_for(project)
    #   project.reports.create!(session: self, author: project.owner)
    #   surveys_per_project = surveys.reject { |s| s.personal? }
    #   surveys_per_project.each do |survey|
    #     if survey.only_for_project_owners?
    #       project.owner.surveys.create!(session: self, survey: survey, project: project)
    #     else
    #       project.members.where(:project_access_state=>:allowed).each do |member|
    #         member.user.surveys.create!(session: self, survey: survey, project: project)
    #       end
    #     end
    #   end
    # end
    #
    # def moderate_included_projects(selected_project_ids)
    #   exclude_projects_from_session(selected_project_ids)
    #   update(involved_project_ids: selected_project_ids)
    # end
    #
    # def exclude_projects_from_session(selected_project_ids)
    #   excluded_project_ids = involved_project_ids.select do |project_id|
    #     !selected_project_ids.include? project_id
    #   end
    #   excluded_projects = ProjectsInSession.where(session: self).where(project_id: excluded_project_ids)
    #   excluded_projects.each { |ip| clear_report_and_surveys_for(ip.project) } if self.active?
    #   excluded_projects.destroy_all
    # end
    #
    # def clear_report_and_surveys_for(project)
    #   project.reports.where(session: self).destroy_all
    #   project.members.where(:project_access_state=>:allowed).each do |member|
    #     member.user.surveys.where(session: self, project: project).destroy_all
    #   end
    #   # TODO Mailer: project is excluded from session.
    #   # Sessions::MailerWorker
    # end

    def validate_reports_and_surveys
      if Sessions.link?(:project)
        reports.where(:state=>:assessed).select(&:failed?).map(&:close_project!)
      end
      reports.where(:state=>[:pending, :accepted, :rejected]).map(&:postdate!)
      notify_experts_about_submitted_reports if reports.where(:state=>:submitted).any?
      notify_experts_about_assessing_reports if reports.where(:state=>:assessing).any?

      user_surveys.where(:state=>[:pending, :filling, :postfilling]).map(&:postdate!)
    end

    def notify_experts_about_submitted_reports
      Sessions::MailerWorker.perform_async(:notify_experts_about_submitted_reports, id)
    end

    def notify_experts_about_assessing_reports
      Sessions.user_class.experts.each do |expert|
        if expert.assesing_reports.any?
          Sessions::MailerWorker.perform_async(:notify_expert_about_assessing_reports, expert.id)
        end
      end
    end
  end
end
