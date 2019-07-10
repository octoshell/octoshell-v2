# encoding: utf-8
# == Schema Information
#
# Table name: sessions_surveys
#
#  id                      :integer          not null, primary key
#  name_en                 :string
#  name_ru                 :string(255)
#  only_for_project_owners :boolean
#  kind_id                 :integer
#  session_id              :integer
#
# Indexes
#
#  index_sessions_surveys_on_kind_id     (kind_id)
#  index_sessions_surveys_on_session_id  (session_id)
#

#
# Опрос. Набор вопросов пользователям.
# Нужен для сбора статистики использования ресурсов по результатам работы.
# Создаётся в начале перерегистрации. При запуске перерегистрации, на основе
# опросников создаются и рассылаются UserSurvey для последюущего заполнения
# пользователями ответами на вопросы из Survey.

module Sessions
  class Survey < ApplicationRecord

    has_paper_trail

    translates :name

    belongs_to :session
    belongs_to :kind, class_name: "Sessions::SurveyKind", foreign_key: :kind_id

    has_many :fields, class_name: "Sessions::SurveyField"
    has_many :user_surveys
    validates_translated :name, presence: true

    def to_s
      kind.name
    end

    def personal?
      !only_for_project_owners
    end

    def template_survey_id
    end
  end
end
