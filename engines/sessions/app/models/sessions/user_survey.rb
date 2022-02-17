# encoding: utf-8
# == Schema Information
#
# Table name: sessions_user_surveys
#
#  id         :integer          not null, primary key
#  state      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#  session_id :integer
#  survey_id  :integer
#  user_id    :integer
#
# Indexes
#
#  index_sessions_user_surveys_on_project_id                (project_id)
#  index_sessions_user_surveys_on_session_id                (session_id)
#  index_sessions_user_surveys_on_session_id_and_survey_id  (session_id,survey_id)
#  index_sessions_user_surveys_on_user_id                   (user_id)
#

# Опрос, который заполняет пользователь
module Sessions
  class UserSurvey < ApplicationRecord



    belongs_to :session
    belongs_to :user, class_name: Sessions.user_class.to_s, inverse_of: :surveys
    belongs_to :survey
    # belongs_to :survey_field
    belongs_to :project, class_name: "Core::Project"

    has_many :values, class_name: "Sessions::SurveyValue", dependent: :destroy

    include AASM
    include ::AASM_Additions
    aasm :state, column: 'state' do
      state :pending, :initial => true
      state :filling
      state :submitted
      state :exceeded   # not submitted and then postdated
      state :postfilling # filling after postdate
      state :postdated  # submitted after postdate

      event :accept do
        transitions :from => :pending, :to => :filling, :after => :fill_fields
      end

      event :submit do
        transitions :from => :filling, :to => :submitted
        transitions :from => :postfilling, :to => :postdated
      end

      event :edit do
        transitions :from => :submitted, :to => :filling
        transitions :from => :exceeded, :to => :postfilling, :after => :fill_fields
        transitions :from => :postfilling, :to => :postfilling, :after => :fill_fields
        transitions :from => :postdated, :to => :postfilling
      end

      event :postdate, after_commit: :block_user do
        transitions :from => [:pending, :filling], :to => :exceeded
      end
    end

    def to_s
      survey.name
    end

    def fill_fields
      survey.fields.each do |field|
        self.values.create!(field: field)
      end
    end

    def block_user
      Sessions::MailerWorker.perform_async(:user_postdated_survey_and_blocked, id)
      user.block! unless user.closed? # TODO block-close do blocked state
    end

    def fill_values(fields)
      transaction do
        saves = fields.to_hash.map do |field_id, value|
          record = values.find { |v| v.survey_field_id == field_id.to_i }
          record.update_value(value)
        end
        if saves.all?
          true
        else
          errors.add(:base, values.map{|v| v.errors.full_messages.to_sentence })
          raise ActiveRecord::Rollback
          false
        end
      end
    end

    def fill_values_and_submit(fields)
      transaction do
        (fill_values(fields) && submit) || raise(ActiveRecord::Rollback)
      end
    end

    def save_as_file(format)
      path = "/tmp/user_survey-#{SecureRandom.hex(4)}.#{format}"
      File.open(path, "wb") do |f|
        f.write send("to_#{format}")
      end
      path
    end

    def as_json(options = nil)
      {
        user_name: user.full_name,
        user_id: user.id,
        values: values.map do |value|
          {
            field: {
              name: value.field.name,
              kind: value.field.kind,
              collection: value.field.collection_values
            },
            value: value.value
          }
        end
      }
    end

    def to_html
      controller = Class.new(AbstractController::Base) do
        include AbstractController::Rendering

        self.view_paths = "app/views"

        def initialize(user_survey)
          @us = user_survey
        end

        def show
          render "sessions/admin/user_surveys/show", layout: "layouts/mini"
        end
      end
      controller.new(self).show
    end
  end
end
