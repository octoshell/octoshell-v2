# encoding: utf-8

# Опрос, который заполняет пользователь
module Sessions
  class UserSurvey < ActiveRecord::Base
    belongs_to :session
    belongs_to :user, class_name: Sessions.user_class, inverse_of: :surveys
    belongs_to :survey
    belongs_to :survey_field
    belongs_to :project, class_name: "Core::Project"

    has_many :values, class_name: "Sessions::SurveyValue", dependent: :destroy

    state_machine :state, initial: :pending do
      state :pending
      state :filling
      state :submitted
      state :exceeded

      event :accept do
        transition pending: :filling
      end

      event :submit do
        transition filling: :submitted
      end

      event :edit do
        transition submitted: :filling
      end

      event :postdate do
        transition [:pending, :filling] => :exceeded
      end

      inside_transition :on => :accept, &:fill_fields
      inside_transition :on => :postdate, &:block_user
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
        saves = fields.map do |field_id, value|
          record = values.find { |v| v.survey_field_id == field_id.to_i }
          record.value = value
          record.save
        end
        saves.all? || (errors.add(:base, values.map{|v| v.errors.full_messages.to_sentence }); raise ActiveRecord::Rollback)
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
