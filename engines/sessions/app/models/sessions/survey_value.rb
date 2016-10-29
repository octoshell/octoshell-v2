# encoding: utf-8

# Значение поля для опроса
# В процессе заполнения опроса Survey пользователь создаёт UserSurvey, заполняя
# SurveyFields из Survey значениями SurveyValue.

module Sessions
  class SurveyValue < ActiveRecord::Base
    belongs_to :user_survey
    belongs_to :field, class_name: "Sessions::SurveyField", foreign_key: :survey_field_id
    belongs_to :reference, polymorphic: true

    delegate :user, to: :user_survey

    validates :field, presence: true

    with_options on: :update do |opt|
      opt.validate :presence_validator, if: :has_presence_validator?
      opt.validates :value, inclusion: { in: proc(&:allowed_values) },
        if: :has_inclusion_validator?
      opt.validate :values_matcher, if: proc { |v| v.multiple_values? && v.field.strict_collection?  }
      opt.validate :regexp_matcher, if: :has_regexp_validator?
      opt.validates :value, numericality: { greater_than_or_equal_to: 0 },
        if: :number_field?
      opt.validate :number_scientometric_validator, if: :number_scientometric_field?
    end

    serialize :value

    def value
      multiple_values? ? Array(self[:value]).select(&:present?) : self[:value]
    end

    def update_value(value)
      self.value = value
      if field.kind == "aselect"
        method = field.strict_collection? ? :find_for_survey! : :find_for_survey
        if record = field.entity_class.send(method, value)
          self.reference = record
        end
      end
      save
    end

    def allowed_values
      field.collection_values
    end

    def has_presence_validator?
      field.required?
    end

    def has_inclusion_validator?
      field.strict_collection? && field.kind.in?(%w(radio select))
    end

    def has_regexp_validator?
      field.regexp.present?
    end

    def multiple_values?
      field.kind.in? %w(mselect uselect aselect)
    end

    def values_matcher
      flag = if multiple_values?
               value.all? do |v|
                 v.in? allowed_values
               end
             else
               value.in? allowed_values
             end
      flag || errors.add("Ответ на вопрос «#{field.name}»", "Непредусмотренное значение")
    end

    def regexp_matcher
      rexp = Regexp.new(field.regexp)
      if multiple_values?
        value.each do |v|
          v.match(rexp) || errors.add("Ответ на вопрос «#{field.name}»", "Не соблюдён формат (см. подсказку к вопросу с правильным форматом)")
        end
      else
        value.match(rexp) || errors.add("Ответ на вопрос «#{field.name}»", "Не соблюдён формат (см. подсказку к вопросу с правильным форматом)")
      end
    end

    def number_field?
      field.kind == 'number'
    end

    def number_scientometric_field?
      field.kind == "scientometrics"
    end

    def number_scientometric_validator
      Array(value).all? do |v|
        v.to_i >= 0
      end || errors.add("Ответ на вопрос «#{field.name}»", "Должно быть больше или равное нулю")
    end

    def presence_validator
      errors.add(:base, "Не заполнен ответ на обязательный для заполнения вопрос: «#{field.name}»") unless value.present?
    end
  end
end
