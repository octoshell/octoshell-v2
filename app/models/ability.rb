# Модель доступа к действию для группы пользователей
class Ability < ActiveRecord::Base
  Definition = Struct.new(:action, :subject)

  belongs_to :group

  validates :action, :subject, :group, presence: true
  validates :action, uniqueness: { scope: [:subject, :group_id] }

  scope :by_definition, ->(definition) { where(action: definition.action, subject: definition.subject) }

  class << self
    def definitions
      raw_definitions.map do |subject, actions|
        actions.map { |a| Definition.new(a.to_sym, subject.to_sym) }
      end.flatten
    end

    def raw_definitions
      YAML.load_file("#{Rails.root}/config/abilities.yml")
    end

    def redefine!
      transaction do
        delete_old
        create_new
      end
    end

    def delete_old
      cases = definitions.map { |d| "#{d.action}#{d.subject}" }
      where("concat(action, subject) not in (?)", cases).delete_all
    end

    def create_new
      Group.all.each do |group|
        definitions.each do |d|
          group.abilities.by_definition(d).first_or_create!
        end
      end
    end

    def default
      definitions.map do |definition|
        new { |a| a.definition = definition }
      end
    end
  end

  def definition=(definition)
    self.action = definition.action
    self.subject = definition.subject
  end

  def description
    I18n.t("abilities.#{subject}.#{action}")
  end

  def action_name
    action.to_sym
  end

  def subject_name
    subject.to_sym
  end

  def to_definition
    Definition.new(action_name, subject_name)
  end
end
