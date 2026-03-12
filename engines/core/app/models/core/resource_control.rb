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

    def build_resource_control_defaults_for_form(access = nil)
      self.access = access if access
      build_resource_control_fields
      return unless self.access&.cluster

      (self.access.cluster.partitions - queue_accesses.map(&:partition)).each do |part|
        queue_accesses.new(partition: part, access_id: self.access.id).mark_for_destruction
      end
    end

    aasm column: :status do
      state :pending, initial: true
      state :active
      state :blocked

      event :activate do
        transitions from: :pending, to: :active
      end

      event :block do
        transitions from: %i[pending active], to: :blocked
      end

      event :unblock do
        transitions from: :blocked, to: :active
      end

      event :check_limit do
        transitions from: %i[pending active], to: :blocked, guard: :exceeded?
        transitions from: %i[pending active], to: :active, guard: -> { !exceeded? }
        transitions from: :blocked, to: :active, guard: -> { !exceeded? }
        transitions from: :blocked, to: :blocked, guard: :exceeded?
      end

      after_all_transitions :sync_queue_accesses
    end

    # Scope for controls that should be included in resource calculation
    # (active and blocked, but not pending)
    def self.calculated
      where(status: %w[active blocked])
    end

    def self.usage_in_node_hours(cluster, controls)
      Core::NodeHourCounterService.new(cluster,
                                       controls.map(&:format_for_counter)).run
    end

    # Calculate resources and update cur_value, but do NOT send emails
    def self.calculate_resources
      calculated
        .includes(access: [{ project: %i[members removed_members] }, :cluster, :resource_users],
                  queue_accesses: :partition)
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
              control.last_sync_at = DateTime.now
              control.check_limit!
            end
          end
        end
    end

    # Send resource usage emails to all recipients (resource users and resource controller)
    def self.send_resource_usage_emails
      # Notify resource controller group (admins)
      Group.find_by_name('resource_controller')&.users&.each do |user|
        Core::MailerWorker.perform_async(:admin_resource_usage, user.id)
      end
      # Notify all resource users (both with member and with email)
      ResourceUser.find_each do |ru|
        Core::MailerWorker.perform_async(:resource_usage, ru.id, ru.access_id)
      end
    end

    def format_for_counter
      {
        start_date: started_at,
        partitions: queue_accesses.map(&:partition).map(&:name),
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

    private

    def sync_queue_accesses
      case aasm.to_state
      when :active
        queue_accesses.each(&:activate!)
      when :blocked
        queue_accesses.each(&:block!)
      end
      # pending: do nothing
    end
  end
end
