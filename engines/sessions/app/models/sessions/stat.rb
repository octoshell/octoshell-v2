# encoding: utf-8

# Статистика по перерегистрации
require "csv"

module Sessions
  class Stat < ActiveRecord::Base
    GROUPS_BY = [:count]

    belongs_to :session
    belongs_to :survey_field, class_name: "Sessions::SurveyField"
    belongs_to :organization, class_name: "Core::Organization"

    validates :session, :survey_field, :group_by, presence: true
    validates :organization, presence: true, if: proc { |s| s.group_by == 'subdivisions' }

    scope :sorted, ->{ order('stats.weight asc') }

    serialize :cache, Array

    def cache!
      self.cache = graph_data
      save!
    end

    def graph_data
      (group_by == "subdivisions") ? graph_data_for_count_in_org : graph_data_for_count
    end

    def graph_data_for_count
      if survey_field.kind == "scientometrics"
        survey_field.collection_values.each_with_index.map do |type, i|
          [type, raw_survey_values.map { |value| value.value[i].to_i }.sum]
        end
      else
        survey_values.group_by{|v| v.to_s.downcase}.map { |k, v| [k, v.size] }.
          sort_by(&:last).reverse
      end
    end

    def graph_data_for_count_in_org
      hash = {}
      organization.departments.each do |department|
        user_surveys = UserSurvey.select(:id).with_state(:submitted).
          where(session_id: session.id).to_sql
        values = SurveyValue.includes(:field).
          joins(user_survey: { user: :employments }).
          where("user_survey_id in (#{user_surveys})").
          where(core_employments: { organization_department_id: department.id }).
          where(survey_field_id: survey_field_id).
          map(&:value).flatten.find_all(&:present?)

        group = values.group_by{|v| v.to_s.downcase}.map { |k, v| [k, v.size] }.
          sort_by(&:last).reverse

        hash[department.name] = group
      end
      hash
    end

    def survey_values
      raw_survey_values.map(&:value).flatten.find_all(&:present?)
    end

    def users_with_value(value)
      raw_survey_values.find_all do |sv|
        Array(sv.value).flatten.map(&:to_s).include?(value)
      end.map(&:user).uniq.sort_by(&:full_name)
    end

    def raw_survey_values
      @raw_survey_values ||= begin
                               user_survey_ids = UserSurvey.with_state(:submitted).where(session_id: session.id).pluck(:id)
                               SurveyValue.where(user_survey_id: user_survey_ids, survey_field_id: survey_field_id).distinct
                             end
    end

    def title
      by = organization ? "по количеству в #{organization.short_name}" : "по количеству"
      "#{survey_field.name} #{by}"
    end

    def to_csv
      CSV.generate(col_sep: ";") do |csv|
        graph_data.each do |row|
          csv << row
        end
      end
    end
  end
end
