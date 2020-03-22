# encoding: utf-8
# == Schema Information
#
# Table name: sessions_stats
#
#  id              :integer          not null, primary key
#  cache           :text
#  group_by        :string(255)      default("count")
#  weight          :integer          default(0)
#  organization_id :integer
#  session_id      :integer
#  survey_field_id :integer
#
# Indexes
#
#  index_sessions_stats_on_session_id                      (session_id)
#  index_sessions_stats_on_session_id_and_organization_id  (session_id,organization_id)
#  index_sessions_stats_on_session_id_and_survey_field_id  (session_id,survey_field_id)
#

# Статистика по перерегистрации
require "csv"

module Sessions
  class Stat < ApplicationRecord
    include StatOrganization
    GROUPS_BY = [:count]

    belongs_to :session
    belongs_to :survey_field, class_name: "Sessions::SurveyField"
    validates :session, :survey_field, :group_by, presence: true

    scope :sorted, ->{ order('stats.weight asc') }

    serialize :cache, Array

    def cache!
      self.cache = graph_data
      save!
    end

    def graph_data
      return graph_data_for_count unless Sessions.link?(:organization)

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
                               user_survey_ids = UserSurvey.where(:state=>:submitted).where(session_id: session.id).pluck(:id)
                               SurveyValue.where(user_survey_id: user_survey_ids, survey_field_id: survey_field_id).distinct
                             end
    end

    def title
      by = if Sessions.link?(:organization) && organization
        "по количеству в #{organization.short_name}"
      else
        "по количеству"
      end
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
