# Модель группы пользователей
class Group < ActiveRecord::Base
  GroupStrata = Struct.new(:name, :weight)
  SUPERADMINS     = GroupStrata.new( "superadmins",     0 )
  FAULTS_MANAGERS = GroupStrata.new( "faults_managers", 1 )
  EXPERTS         = GroupStrata.new( "experts",         2 )
  SUPPORT         = GroupStrata.new( "support",         3 )
  AUTHORIZED      = GroupStrata.new( "authorized",      4 )
  REREGISTRATORS  = GroupStrata.new( "reregistrators",  5 )

  DEFAULT_STRATAS = [ SUPERADMINS, AUTHORIZED,
                      FAULTS_MANAGERS, EXPERTS,
                      SUPPORT, REREGISTRATORS ]

  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups
  has_many :abilities, dependent: :destroy

  accepts_nested_attributes_for :abilities

  after_create :create_abilities

  validates :name, presence: true, uniqueness: true

  class << self
    DEFAULT_STRATAS.each do |strata|
      define_method strata.name do
        where(name: strata.name).first_or_create do |group|
          group.system = true
        end
      end
    end

    def default!
      Ability.redefine!
      transaction do
        DEFAULT_STRATAS.each do |strata|
          self.send(strata.name).abilities.update_all available: false
        end
      end
      superadmins.abilities.update_all available: true
      defaults = YAML.load_file "#{Rails.root}/config/groups.default.yml"
      defaults.each do |group, abilities|
        abilities.each do |subject, actions|
          send(group).abilities.where(subject: subject, action: actions).
            update_all(available: true)
        end
      end
    end
  end

private

  def create_abilities
    Ability.definitions.each do |definition|
      abilities.create! do |a|
        a.definition = definition
        a.available = (name == SUPERADMINS.name)
      end
    end
    true
  end
end
