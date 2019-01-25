# encoding: utf-8

# == Schema Information
#
# Table name: core_project_cards
#
#  id           :integer          not null, primary key
#  project_id   :integer
#  name         :text
#  en_name      :text
#  driver       :text
#  en_driver    :text
#  strategy     :text
#  en_strategy  :text
#  objective    :text
#  en_objective :text
#  impact       :text
#  en_impact    :text
#  usage        :text
#  en_usage     :text
#  created_at   :datetime
#  updated_at   :datetime
#


# Карточка проекта
module Core
  class ProjectCard < ActiveRecord::Base
    RU_FIELDS = [:name, :driver, :strategy, :objective, :impact, :usage]
    EN_FIELDS = [:en_name, :en_driver, :en_strategy, :en_objective, :en_impact,
      :en_usage]

    ALL_FIELDS = RU_FIELDS | EN_FIELDS

    belongs_to :project, inverse_of: :card

    validates *(ALL_FIELDS + [:project]), presence: true
    validates *RU_FIELDS, format: { with: /\A[а-яёa-z№\d[:space:][:punct:]\+]+\z/i, message: I18n.t("errors.must_be_in_russian") }
    validates *EN_FIELDS, format: { with: /\A[a-z\d[:space:][:punct:]\+]+\z/i, message: I18n.t("errors.must_be_in_english") }
  end
end
