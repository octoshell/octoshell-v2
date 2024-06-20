# == Schema Information
#
# Table name: permissions
#
#  id            :integer          not null, primary key
#  action        :string(255)
#  subject_class :string(255)
#  group_id      :integer
#  available     :boolean          default("false")
#  created_at    :datetime
#  updated_at    :datetime
#  subject_id    :integer
#
# Indexes
#
#  index_permissions_on_group_id  (group_id)
#

# Модель доступа к действию для группы пользователей
class Permission < ApplicationRecord
  Definition = Struct.new(:action, :subject_class)

  belongs_to :group

  validates :action, :subject_class, :group, presence: true
  validates :action, uniqueness: { scope: %i[subject_class group_id subject_id] }

  scope :by_definition, ->(definition) { where(action: definition.action,
                                               subject_class: definition.subject_class) }
  belongs_to :subject, foreign_key: :subject_id, foreign_type: :subject_class, polymorphic: true

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
      cases = definitions.map { |d| "#{d.action}#{d.subject_class}" }
      where("concat(action, subject_class) not in (?)", cases).delete_all
    end

    def create_new
      Group.all.each do |group|
        definitions.each do |d|
          group.permissions.by_definition(d).first_or_create!
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
    self.subject_class = definition.subject_class
  end

  def description
    I18n.t("abilities.#{subject_class}.#{action}")
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
