# Поле опроса
module Sessions
  class SurveyField < ActiveRecord::Base
    include ActionView::Helpers::JavaScriptHelper

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

    scope :sorted, -> { order("#{table_name}.weight asc, #{table_name}.name asc") }

    validates :name, :kind, presence: true

    def name
      self[:name].to_s.html_safe
    end

    def collection_values
      collection.each_line.find_all(&:present?).map(&:strip)
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
