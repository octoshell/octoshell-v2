module Sessions
  class Mailer < ActionMailer::Base
    def project_failed_session(report_id)
      @report = Sessions::Report.find(report_id)
      @user = @report.author
      @project = @report.project
      mail to: @user.email, subject: t(".subject", id: report_id, title: @project.title)
    end

    def new_report(report_id)
      @report = Sessions::Report.find(report_id)
      @user = @report.author
      @project = @report.project
      mail to: @user.email, subject: t(".subject", title: @project.title)
    end

    def report_submitted(report_id)
      @report = Sessions::Report.find(report_id)
      @project = @report.project
      expert_emails = Sessions.user_class.experts.map(&:email)
      mail to: expert_emails, subject: t(".subject", id: report_id, title: @project.title)
    end

    def report_rejected(report_id)
      @report = Sessions::Report.find(report_id)
      @project = @report.project
      @user = @report.author
      mail to: @user.email, subject: t(".subject", id: report_id, title: @project.title)
    end

    def report_picked(report_id)
      @report = Sessions::Report.find(report_id)
      @project = @report.project
      @user = @report.author
      mail to: @user.email, subject: t(".subject", id: report_id, title: @project.title)
    end

    def report_assessed(report_id)
      @report = Sessions::Report.find(report_id)
      @project = @report.project
      @user = @report.author
      mail to: @user.email, subject: t(".subject", id: report_id, title: @project.title)
    end

    def report_resubmitted(report_id)
      @report = Sessions::Report.find(report_id)
      @project = @report.project
      @user = @report.expert
      mail to: @user.email, subject: t(".subject", id: report_id, title: @project.title)
    end

    def report_reply(user_id, report_id)
      @user = Sessions.user_class.find(user_id)
      @report = Sessions::Report.find(report_id)
      mail to: @user.email, subject: t(".subject", id: report_id, title: @report.project.title)
    end

    def notify_exerts_about_submitted_reports(session_id)
      @session = Sessions::Session.find(session_id)
      @submitted_reports = @session.reports.with_state(:submitted)
      expert_emails = Sessions.user_class.experts.map(&:email)
      mail to: expert_emails, subject: t(".subject", count: @submitted_reports.count)
    end

    def notify_expert_about_assessing_reports(user_id)
      @user = Sessions.user_class.find(user_id)
      mail to: @user.email, subject: t(".subject", count: @user.assessing_reports.count)
    end

    def postdated_report_on_project(report_id)
      @report = Sessions::Report.find(report_id)
      @project = @report.project
      @user = @report.author
      mail to: @user.email, subject: t(".subject", id: report_id, title: @project.title)
    end

    def user_postdated_survey_and_blocked(user_survey_id)
      @user_survey = Sessions::UserSurvey.find(user_survey_id)
      @user = @user_survey.user
      mail to: @user.email, subject: t(".subject", name: @user_survey.survey.name, title: @user_survey.project.title)
    end
  end
end
