class AddTranslationColumns < ActiveRecord::Migration
  def change
    add_column :announcements, :title_en, :string
    add_column :announcements, :body_en, :text
    add_column :core_clusters, :name_en, :string
    add_column :core_critical_technologies, :name_en, :string
    add_column :core_direction_of_sciences, :name_en, :string
    add_column :core_employment_position_names, :name_en, :string
    add_column :core_employment_position_names, :autocomplete_en, :text
    add_column :core_organization_kinds, :name_en, :string
    add_column :core_quota_kinds, :name_en, :string
    add_column :core_research_areas, :name_en, :string
    add_column :pack_packages, :description_en, :text
    add_column :pack_versions, :description_en, :text
    add_column :sessions_report_submit_denial_reasons, :name_en, :string
    add_column :sessions_sessions, :description_en, :text
    add_column :sessions_sessions, :motivation_en, :text
    add_column :sessions_survey_fields, :collection_en, :text
    add_column :sessions_survey_fields, :name_en, :string
    add_column :sessions_surveys, :name_en, :string
    add_column :support_fields, :name_en, :string
    add_column :support_fields, :hint_en, :string
    add_column :support_reply_templates, :subject_en, :string
    add_column :support_reply_templates, :message_en, :text
    add_column :support_tags, :name_en, :string
    add_column :support_topics, :name_en, :string
    add_column :wiki_pages, :name_en, :string
    add_column :wiki_pages, :content_en, :text
  end
end
