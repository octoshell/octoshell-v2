class SessionsPreview
  def project_failed_session
    ::Sessions::Mailer.project_failed_session(Sessions::Report.first.id)
  end

  def new_report
    ::Sessions::Mailer.new_report(Sessions::Report.first.id)
  end

  def report_submitted
    ::Sessions::Mailer.report_submitted(Sessions::Report.first.id)
  end

  def report_rejected
    ::Sessions::Mailer.report_rejected(Sessions::Report.first.id)
  end

  def report_picked
    ::Sessions::Mailer.report_picked(Sessions::Report.first.id)
  end

  def report_assessed
    ::Sessions::Mailer.report_assessed(Sessions::Report.first.id)
  end

  def report_resubmitted
    ::Sessions::Mailer.report_resubmitted(Sessions::Report.first.id)
  end

  def report_reply
    ::Sessions::Mailer.report_reply(Sessions.user_class.first.id,Sessions::Report.first.id)
  end

  def notify_experts_about_submitted_reports
    ::Sessions::Mailer.notify_experts_about_submitted_reports(Sessions::Session.first.id)
  end

  def notify_expert_about_assessing_reports
    ::Sessions::Mailer.notify_expert_about_assessing_reports(Sessions::Session.first.id)
  end

  def postdated_report_on_project
    ::Sessions::Mailer.postdated_report_on_project(Sessions::Report.first.id)
  end

  def user_postdated_survey_and_blocked
    ::Sessions::Mailer.user_postdated_survey_and_blocked(Sessions::UserSurvey.first.id)
  end

end
