module Core
  class ResourceControl < ApplicationRecord
    include AASM
    include ::AASM_Additions

    belongs_to :access, inverse_of: :resource_controls
    has_many :resource_control_fields, inverse_of: :resource_control
    has_many :resource_control_partitions, inverse_of: :resource_control, dependent: :destroy
    accepts_nested_attributes_for :resource_control_fields, :resource_control_partitions, allow_destroy: true
    validates :access, :status, :started_at, presence: true
    validates :resource_control_partitions, length: { minimum: 1 }
    before_destroy do
      throw(:abort) if may_destroy?
    end

    def build_resource_control_defaults_for_form(access = nil)
      self.access = access if access
      build_resource_control_fields
      return unless self.access&.cluster

      (self.access.cluster.partitions - resource_control_partitions.map(&:partition)).each do |part|
        resource_control_partitions.new(partition: part).mark_for_destruction
      end
    end

    aasm(column: :status) do
      state :pending, initial: true
      state :active
      state :blocked
      state :disabled

      event :enable do
        transitions from: %i[pending disabled], to: :blocked, guard: :exceeded?
        transitions from: %i[pending disabled], to: :active, guard: -> { !exceeded? }
        before do
          self.synced_with_cluster = false
        end
      end

      event :change_cluster_state do
        transitions from: %i[active], to: :blocked, guard: :exceeded?
        transitions from: %i[blocked], to: :active, guard: -> { !exceeded? }
        before do
          self.synced_with_cluster = false
        end
      end

      event :disable do
        transitions from: %i[pending blocked active], to: :disabled
        before do
          self.synced_with_cluster = false
        end
      end

      after_all_transitions :enqueue_synchronize
    end

    def fix_sync_timestamp
      update!(last_sync_at: DateTime.current, synced_with_cluster: true)
    end

    def synchronize(connection = nil)
      if active?
        resource_control_partitions.each do |r_p|
          r_p.activate(connection)
        end
        fix_sync_timestamp
      elsif blocked? || disabled?
        resource_control_partitions.each do |r_p|
          r_p.block(connection)
        end
        fix_sync_timestamp
      else
        nil
      end
    end

    def enqueue_synchronize
      SshWorker.perform_async(:synchronize, id)
    end

    def self.synchronize(id)
      find(id).synchronize
    end

    def self.usage_in_node_hours(cluster, controls)
      NodeHourCounterService.new(cluster,
                                 controls.map(&:format_for_counter)).run
    end

    def self.calculated
      where(status: %w[active blocked])
    end

    # Calculate resources and update cur_value, but do NOT send emails
    def self.calculate_resources
      calculated
        .includes(access: [{ project: %i[members removed_members] }, :cluster, :resource_users],
                  resource_control_partitions: :partition)
        .group_by { |r| r.access.cluster }
        .each do |cluster, controls|
          results = usage_in_node_hours(cluster, controls)
          transaction do
            controls.each_with_index do |control, i|
              result = results[i]
              control.resource_control_fields.joins(:quota_kind)
                     .where(core_quota_kinds: { api_key: 'node_hours' })
                     .first&.update!(cur_value: result[0])
              if result[1]&.present?
                cluster.log("ResourceControl##{control.id}: #{result[1]}",
                            control.access.project)
              end
              control.change_cluster_state! if control.may_change_cluster_state?
            end
          end
        end
    end

    # Send resource usage emails to all recipients (resource users and resource controller)
    def self.send_resource_usage_emails
      # Notify resource controller group (admins)
      Group.find_by_name('resource_controller')&.users&.each do |user|
        MailerWorker.perform_async(:admin_resource_usage, user.id)
      end
      # Notify all resource users (both with member and with email)
      ResourceUser.find_each do |ru|
        MailerWorker.perform_async(:resource_usage, [ru.id, ru.access_id])
      end
    end

    def format_for_counter
      {
        start_date: started_at,
        partitions: resource_control_partitions.map(&:partition).map(&:name),
        logins: access.project.members.map(&:login) |
          access.project.removed_members.map(&:login)
      }
    end

    def exceeded?
      resource_control_fields.any?(&:exceeded?)
    end

    def available_partitions
      access.cluster.partitions
    end

    def build_resource_control_fields
      QuotaKind.where("api_key is not null AND api_key != ''").each do |kind|
        unless resource_control_fields.any? { |f| f.quota_kind_id == kind.id }
          resource_control_fields.build(quota_kind: kind)
        end
      end
    end

    def may_destroy?
      disabled? && synced_with_cluster || pending?
    end

    def field_by_quota_kind(quota_kind)
      resource_control_fields.detect { |f| f.quota_kind_id == quota_kind.id }
    end
  end
end
