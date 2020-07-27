# encoding: utf-8

User.class_eval do
  has_one :profile, inverse_of: :user, dependent: :destroy

  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :permissions, through: :groups

  validates :language, inclusion: { in: I18n.available_locales.map(&:to_s) }

  # delegate :initials, :full_name, to: :profile

  after_create :create_profile!
  after_create :setup_default_groups

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :groups

  before_validation do
    self.language ||= I18n.default_locale.to_s
  end

  scope :finder, (lambda do |q|
    string = %w[profiles.last_name profiles.first_name profiles.middle_name email].join("||' '||")
    #!!! WARNING !!! Postgresql extension!!!
  end)

  scope :logins, (lambda do |q|
    Core::Member.where("login ILIKE ?","%#{q}%").map{|a| {id: a.user_id, login: a.login}}
  end)

  def as_json(_options)
    { id: id, text: full_name_with_email }
  end

  def to_s
    full_name
  end

  interface do
    #email
    def full_name
      profile.full_name
    end

    def initials
      profile.initials
    end

    def full_name_with_email
      [full_name, email].join(" ")
    end

    def cut_email
      to_swap = email.rpartition('@').last.rpartition('.').first
      if to_swap.length >= 2
        modified = to_swap[0] + '*' + to_swap[-1]
      else
        modified = to_swap
      end
      email.gsub(/@#{to_swap}/, "@#{modified}")
    end

    def full_name_with_cut_email
      [full_name, cut_email].join(" ")
    end

    def mailsender?
      groups.where(name: 'mailsenders').any?
    end
  end

  def self.superadmins
    Group.superadmins.users
  end

  def self.support
    Group.support.users
  end

  def self.experts
    Group.experts.users
  end

  def self.reregistrators
    Group.reregistrators.users
  end

  private

  def setup_default_groups
    user_groups.where(group_id: Group.authorized.id).first_or_create!
    true
  end
end
