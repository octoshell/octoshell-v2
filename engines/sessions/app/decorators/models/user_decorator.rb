# encoding: utf-8

Sessions.user_class.class_eval do
  has_many :surveys, class_name: "Sessions::UserSurvey", dependent: :destroy
  has_many :sessions, class_name: "Sessions::Session", through: :surveys
  has_many :reports, class_name: "Sessions::Report", foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :assessing_reports, -> { where(state: :assessing) },
                               class_name: "Sessions::Report",
                               foreign_key: :expert_id,
                               source: :report, inverse_of: :expert
end if Sessions.user_class
