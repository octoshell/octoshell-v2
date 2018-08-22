class AddTranslationColumns < ActiveRecord::Migration
  def change
    rename_column :announcements, :title, :title_ru
    add_column :announcements, :title_en, :string
    rename_column :announcements, :body, :body_ru
    add_column :announcements, :body_en, :text
    rename_column :core_clusters, :name, :name_ru
    add_column :core_clusters, :name_en, :string
    rename_column :core_critical_technologies, :name, :name_ru
    add_column :core_critical_technologies, :name_en, :string
    rename_column :core_direction_of_sciences, :name, :name_ru
    add_column :core_direction_of_sciences, :name_en, :string
    rename_column :core_employment_position_names, :name, :name_ru
    add_column :core_employment_position_names, :name_en, :string
    rename_column :core_organization_kinds, :name, :name_ru
    add_column :core_organization_kinds, :name_en, :string
    rename_column :core_quota_kinds, :name, :name_ru
    add_column :core_quota_kinds, :name_en, :string
    rename_column :core_quota_kinds, :measurement, :measurement_ru
    add_column :core_quota_kinds, :measurement_en, :string
    rename_column :core_project_kinds, :name, :name_ru
    add_column :core_project_kinds, :name_en, :string
    rename_column :core_research_areas, :name, :name_ru
    add_column :core_research_areas, :name_en, :string

    rename_column :comments_contexts, :name, :name_ru
    add_column :comments_contexts, :name_en, :string


    rename_column :pack_packages, :description, :description_ru
    add_column :pack_packages, :description_en, :text
    rename_column :pack_packages, :name, :name_ru
    add_column :pack_packages, :name_en, :string
    rename_column :pack_versions, :description, :description_ru
    add_column :pack_versions, :description_en, :text
    rename_column :pack_versions, :name, :name_ru
    add_column :pack_versions, :name_en, :string
    rename_column :pack_version_options, :name, :name_ru
    add_column :pack_version_options, :name_en, :string
    rename_column :pack_version_options, :value, :value_ru
    add_column :pack_version_options, :value_en, :string
    rename_column :pack_options_categories, :category, :category_ru
    add_column :pack_options_categories, :category_en, :string




    rename_column :sessions_report_submit_denial_reasons, :name, :name_ru
    add_column :sessions_report_submit_denial_reasons, :name_en, :string
    rename_column :sessions_sessions, :description, :description_ru
    add_column :sessions_sessions, :description_en, :text
    rename_column :sessions_sessions, :motivation, :motivation_ru
    add_column :sessions_sessions, :motivation_en, :text
    rename_column :sessions_survey_fields, :hint, :hint_ru
    add_column :sessions_survey_fields, :hint_en, :string
    rename_column :sessions_survey_fields, :name, :name_ru
    add_column :sessions_survey_fields, :name_en, :string
    rename_column :sessions_surveys, :name, :name_ru
    add_column :sessions_surveys, :name_en, :string

    rename_column :support_fields, :name, :name_ru
    add_column :support_fields, :name_en, :string
    rename_column :support_fields, :hint, :hint_ru
    add_column :support_fields, :hint_en, :string
    rename_column :support_reply_templates, :subject, :subject_ru
    add_column :support_reply_templates, :subject_en, :string
    rename_column :support_reply_templates, :message, :message_ru
    add_column :support_reply_templates, :message_en, :text
    rename_column :support_tags, :name, :name_ru
    add_column :support_tags, :name_en, :string
    rename_column :support_topics, :name, :name_ru
    add_column :support_topics, :name_en, :string
    
    rename_column :wiki_pages, :name, :name_ru
    add_column :wiki_pages, :name_en, :string
    rename_column :wiki_pages, :content, :content_ru
    add_column :wiki_pages, :content_en, :text
  end
end
