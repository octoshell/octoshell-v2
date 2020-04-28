module Sessions
  module StatOrganization
    extend ActiveSupport::Concern
    included do
      octo_use(:organization_class, :core, 'Organization')
      belongs_to :organization, class_name: organization_class_to_s
      validates :organization, presence: true, if: proc { |s| s.group_by == 'subdivisions' }
    end

    def graph_data
      if group_by == "subdivisions"
        graph_data_for_count_in_org
      else
        graph_data_for_count
      end
    end

    def graph_data_for_count_in_org
      hash = {}
      organization.departments.each do |department|
        user_surveys = UserSurvey.select(:id).where(:state=>:submitted).
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

    def title
      by = if organization
        "по количеству в #{organization.short_name}"
      else
        "по количеству"
      end
      "#{survey_field.name} #{by}"
    end


  end
end
