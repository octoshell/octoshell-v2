# encoding: utf-8
#
# Опрос. Набор вопросов пользователям.
# Нужен для сбора статистики использования ресурсов по результатам работы.
# Создаётся в начале перерегистрации. При запуске перерегистрации, на основе
# опросников создаются и рассылаются UserSurvey для последюущего заполнения
# пользователями ответами на вопросы из Survey.

module Sessions
  class Survey < ActiveRecord::Base
    belongs_to :session
    belongs_to :kind, class_name: "Sessions::SurveyKind", foreign_key: :kind_id

    has_many :fields, class_name: "Sessions::SurveyField"
    has_many :user_surveys

    def to_s
      kind.name
    end

    def personal?
      name =~ /персональный/i
    end

    def template_survey_id
    end
  end
end
