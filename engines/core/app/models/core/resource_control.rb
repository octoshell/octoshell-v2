module Core
  class ResourceControl < ApplicationRecord
    include AASM
    include ::AASM_Additions

    belongs_to :access, inverse_of: :resource_controls
    has_many :resource_control_fields, inverse_of: :resource_control
    has_many :resource_control_partitions, lambda {
      joins(:partition).order('core_partitions.resource_control_weight DESC')
    }, inverse_of: :resource_control, dependent: :destroy
    accepts_nested_attributes_for :resource_control_fields, :resource_control_partitions, allow_destroy: true
    validates :access, :status, :started_at, presence: true
    validates :resource_control_partitions, length: { minimum: 1 }
    before_destroy do
      throw(:abort) unless may_destroy?
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

    def self.calculated
      where(status: %w[active blocked])
    end

    # Parse the output of Cluster#jobs_in_period into an array of job hashes.
    # Each hash contains :user, :elapsed, :nnodes, :start.
    def self.parse_jobs_output(output)
      return [] if output.blank?

      lines = output.strip.split("\n")
      # Skip header line if present (optional)
      lines.shift if lines.first&.match?(/^User\|Partition\|Elapsed\|NNodes\|Start\|End\|State$/)
      lines.map do |line|
        fields = line.split('|')
        next if fields.size < 7

        {
          user: fields[0]&.strip,
          partition: fields[1]&.strip,
          elapsed: fields[2]&.strip,
          nnodes: fields[3]&.strip,
          start: fields[4]&.strip,
          end: fields[5]&.strip,
          state: fields[6]&.strip
        }
      end.compact
    end

    def update_consumed_resources(jobs)
      field = resource_control_fields.joins(:quota_kind)
                                     .where(core_quota_kinds: { api_key: 'node_hours' })
                                     .first
      node_hours = node_hours_from_jobs(jobs)
      field&.update!(cur_value: node_hours)
      change_cluster_state! if may_change_cluster_state?
    end

    # Instance method to compute node‑hours for this control from a list of jobs.
    # Returns node_hours as Float
    def node_hours_from_jobs(jobs)
      return 0.0 if jobs.blank?

      logins = access.project.members.map(&:login) | access.project.removed_members.map(&:login)
      allowed_partitions = resource_control_partitions.map(&:partition).map(&:name)
      total = 0.0

      jobs.each do |job|
        next unless logins.include?(job[:user])
        next unless allowed_partitions.include?(job[:partition])

        job_start = ::Core::SlurmTimeParser.parse_time_string(job[:start])
        next if job_start.nil? || job_start < started_at

        elapsed_hours = ::Core::SlurmTimeParser.elapsed_to_hours(job[:elapsed])
        nnodes = job[:nnodes].to_i
        total += elapsed_hours * nnodes
      end

      total.round(6)
    end

    # Calculate resources and update cur_value
    def self.calculate_resources
      calculated
        .includes(access: [{ project: %i[members removed_members] }, :cluster, :resource_users],
                  resource_control_partitions: :partition)
        .group_by { |r| r.access.cluster }
        .each do |cluster, controls|
          # Determine the earliest started_at among controls to limit the jobs query
          earliest_start = controls.map(&:started_at).min
          jobs_output = cluster.jobs_in_period(earliest_start, Time.current)
          jobs = parse_jobs_output(jobs_output)

          transaction do
            controls.each do |control|
              control.update_consumed_resources(jobs)
            end
          end
        end
    end

    # Notify resource controller group (admins)
    def self.send_resource_usage_emails_for_admins
      Group.find_by_name('resource_controller')&.users&.each do |user|
        MailerWorker.perform_async(:admin_resource_usage, user.id)
      end
    end

    # Notify all resource users (both with member and with email)
    def self.send_resource_usage_emails_for_users
      ResourceUser.find_each do |ru|
        MailerWorker.perform_async(:resource_usage, [ru.id, ru.access_id])
      end
    end

    # Send resource usage emails to all recipients (resource users and resource controller)
    def self.send_resource_usage_emails
      send_resource_usage_emails_for_admins
      send_resource_usage_emails_for_users
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
