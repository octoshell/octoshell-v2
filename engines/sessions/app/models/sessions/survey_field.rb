# Поле опроса
module Sessions
  class SurveyField < ActiveRecord::Base
    include ActionView::Helpers::JavaScriptHelper
    translates :name, :hint

    KINDS = [:radio, :select, :mselect, :uselect, :string, :text, :number, :scientometrics, :string_scientometrics]
    KINDS_COLLECTION = begin
                         Hash[KINDS.map do |kind|
                           [I18n.t("survey_field_kinds.#{kind}"), kind]
                         end]
                       end
    ENTITIES = [:organization, :positions]
    ENTITIES_COLLECTION = begin
                            Hash[ENTITIES.map do |entity|
                              [I18n.t("survey_field_entities.#{entity}"), entity]
                            end]
                          end
    ENTITIES_CLASSES = {
      organization: 'Organization',
      positions: 'Position'
    }

    belongs_to :survey

    scope :sorted, -> { order("#{table_name}.weight asc, #{table_name}.#{current_locale_column(:name)} asc") }

    validates :kind, presence: true
    validates_translated :name, presence: true

    # def name
    #   self[self.class.current_locale_column(:name)].to_s.html_safe
    # end

    def collection_values
      collection.each_line.find_all(&:present?).map(&:strip)
    end

    def collection_values_translated?
      collection_values.all? do |v|
        (I18n.available_locales.count - v.split('|').count).zero?
      end
    end

    def localized_collection_values
      return collection_values unless collection_values_translated?
      index = I18n.available_locales.find_index { |l| l == I18n.locale }
      collection_values.map do |value|
        value.split('|')[index]
      end
    end

    def entity_source
      case entity.to_sym
      when :organization then
        '/organizations.json'
      when :positions then
        '/positions.json'
      end
    end

    def entity_class
      ENTITIES_CLASSES[entity.to_sym].constantize
    end

    def group
      survey.name
    end
  end
end
