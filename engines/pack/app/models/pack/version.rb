# == Schema Information
#
# Table name: pack_versions
#
#  id               :integer          not null, primary key
#  cost             :integer
#  delete_on_expire :boolean          default(FALSE), not null
#  deleted          :boolean          default(FALSE), not null
#  description_en   :text
#  description_ru   :text
#  end_lic          :date
#  lock_col         :integer          default(0), not null
#  name_en          :string
#  name_ru          :string
#  service          :boolean          default(FALSE), not null
#  state            :string
#  ticket_created   :boolean          default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#  package_id       :integer
#  ticket_id        :integer
#
# Indexes
#
#  index_pack_versions_on_package_id  (package_id)
#

module Pack
  class Version < ApplicationRecord
    include AASM
    translates :description, :name
    validates_translated :name, :description, presence: true
    validates_translated :name, uniqueness: { scope: :package_id }
    extend_with_options
    validates :package, presence: true
    belongs_to :package, inverse_of: :versions
    # belongs_to :ticket, class_name: 'Support::Ticket'
    has_many :clustervers, inverse_of: :version, dependent: :destroy
    has_many :version_options, inverse_of: :version, dependent: :destroy
    # has_many :options_categories, through: :version_options
    # has_many :category_values, through: :version_options
    has_many :accesses, dependent: :destroy, as: :to
    # accepts_nested_attributes_for :version_options,:clustervers, allow_destroy: true
    accepts_nested_attributes_for :clustervers, allow_destroy: true
    # validates_associated :version_options,:clustervers
    validates_associated :clustervers
    scope :finder, lambda { |q|
      where('lower(name_ru) like lower(:q) OR lower(name_en) like lower(:q)', q: "%#{q.mb_chars}%").limit(10)
    }
    # validate :date_and_state, :work_with_stale, :pack_deleted
    validate :date_and_state, :pack_deleted

    before_validation :change_state, if: -> { end_lic.present? }

    before_save :delete_accesses, :make_clvers_not_active, :remove_ticket, :change_state

    aasm column: :state do
      state :forever, :available, :expired
      event :to_expired do
        transitions from: :available, to: :expired
      end
    end

    def self.ransackable_scopes(_auth_object = nil)
      %i[end_lic_greater]
    end

    def self.end_lic_greater(date)
      where(['pack_versions.end_lic > ? OR pack_versions.end_lic IS NULL', Date.parse(date)])
    end

    def pack_deleted
      return unless package&.deleted && !deleted

      errors.add(:deleted, :pack_deleted)
    end

    def remove_ticket
      return unless end_lic.blank? || end_lic > Date.today + Pack.expire_after

      self.ticket_created = false
    end

    def delete_accesses
      self.deleted = true if deleted == true || package.deleted == true
      return unless deleted == true || state == 'expired' && delete_on_expire

      accesses.load
      accesses.each do |a|
        a.status = 'deleted'
        a.save
      end
    end

    def make_clvers_not_active
      return unless deleted == true

      clustervers.where(active: true).each do |cl|
        cl.active = false
        cl.save
      end
    end

    def change_state
      return if state == 'forever'

      self.state = if end_lic >= Date.current
                     'available'
                   else
                     'expired'
                   end
    end

    def end_lic_readable
      end_lic || Access.human_attribute_name(:forever)
    end

    after_commit :send_emails

    def send_emails
      return unless previous_changes['state']

      accesses.where("pack_accesses.who_type in ('User','Core::Project') AND pack_accesses.status IN ('allowed','expired')").each do |ac|
        ::Pack::PackWorker.perform_async(:version_state_changed, [ac.id, id])
      end
      package.accesses.where("pack_accesses.who_type in ('User','Core::Project') AND pack_accesses.status IN ('allowed','expired')").each do |ac|
        ::Pack::PackWorker.perform_async(:version_state_changed, [ac.id, id])
      end
    end

    def self.expired_versions
      Version.transaction do
        where("end_lic IS NOT NULL and end_lic < ? and state='available'", Date.today).each do |ac|
          ac.update!(state: 'expired')
        end
      end
    end

    def self.expiring_versions_without_ticket
      where("end_lic IS NOT NULL and end_lic < ?
            AND state='available'", Date.today + Pack.expire_after)
        .where(ticket_created: false)
    end
    where("end_lic IS NOT NULL and end_lic < ? AND state='available'", Date.today).where(ticket_created: false)

    def self.notify_about_expiring_versions
      return unless expiring_versions_without_ticket.exists?

      versions = expiring_versions_without_ticket.to_a
      return unless Octoface.role_class?(:support, 'Notificator')

      Version.transaction do
        Notificator.notify_about_expiring_versions(expiring_versions_without_ticket)
        versions.each do |version|
          version.update!(ticket_created: true)
        end
      end
    end

    def self.allowed_for_users
      where("pack_versions.service= 'f' OR pack_accesses.status='allowed'")
    end

    def self.allowed_for_users_with_joins(user_id)
      allowed_for_users.user_access(user_id, 'LEFT')
    end

    def self.user_access(user_id, join_type)
      user_id = 1 if user_id == true
      join_accesses self, user_id, join_type
    end

    def name_with_package
      "#{name}   #{I18n.t('Package_name')}: #{package.name}"
    end

    def self.join_accesses(relation, user_id, join_type)
      join_string = "(pack_accesses.to_id = pack_versions.id AND pack_accesses.to_type = 'Pack::Version' OR
                      pack_accesses.to_id = pack_packages.id AND pack_accesses.to_type = 'Pack::Package')"
      if relation.all.klass == Pack::Version
        relation = relation.joins('LEFT OUTER JOIN pack_packages ON pack_packages.id = pack_versions.package_id')
      end
      project_accesses = relation.joins(
        <<-EORUBY
          LEFT JOIN "core_members" ON ( "core_members"."user_id" = #{user_id}   )
          #{join_type} JOIN  pack_accesses ON (#{join_string}
          AND "pack_accesses"."who_type" = 'Core::Project'
          AND core_members.project_id = pack_accesses.who_id)
        EORUBY
      )
      group_accesses = relation.joins(
        <<-EORUBY
         LEFT JOIN "user_groups" ON ("user_groups"."user_id" = #{user_id}  )
           #{join_type} JOIN  pack_accesses ON (#{join_string} AND "pack_accesses"."who_type" = 'Group'
          AND user_groups.group_id = pack_accesses.who_id)
        EORUBY
      )
      user_accesses = relation.joins(
        <<-EORUBY
          #{join_type} JOIN  pack_accesses ON (#{join_string} AND "pack_accesses"."who_type" = 'User'
          AND #{user_id} = pack_accesses.who_id)
        EORUBY
      )
      project_accesses.union(group_accesses).union(user_accesses)
    end

    def deleted?
      deleted || package.deleted
    end

    def available_for_user?
      %w[available forever].include?(state) && !deleted?
    end

    def readable_state
      I18n.t "versions.#{state}"
    end

    def date_and_state
      if state == 'forever' && end_lic
        errors.add(:end_lic, :present)
      elsif state != 'forever' && !end_lic
        errors.add(:end_lic, :blank)
      end
    end

    def build_clusterver(cluster)
      clustervers.new(core_cluster: cluster).mark_for_destruction
    end

    def build_clustervers
      cluster_ids = clustervers.map(&:core_cluster_id)
      ::Core::Cluster.all.each do |cluster|
        build_clusterver(cluster) if cluster_ids.exclude? cluster.id
      end
    end

    def as_json(_options = nil)
      { id: id, text: (name + package_id.to_s) }
    end

    def to_s
      "#{self.class.model_name.human} \"#{name}\""
    end
  end
end
