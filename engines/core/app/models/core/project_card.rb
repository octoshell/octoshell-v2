# encoding: utf-8
# == Schema Information
#
# Table name: core_project_cards
#
#  id           :integer          not null, primary key
#  driver       :text
#  en_driver    :text
#  en_impact    :text
#  en_name      :text
#  en_objective :text
#  en_strategy  :text
#  en_usage     :text
#  impact       :text
#  name         :text
#  objective    :text
#  strategy     :text
#  usage        :text
#  created_at   :datetime
#  updated_at   :datetime
#  project_id   :integer
#
# Indexes
#
#  index_core_project_cards_on_project_id  (project_id)
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
