module Core
  class ResourceControl < ApplicationRecord
    include StringEnum
    belongs_to :access, inverse_of: :resource_controls
    has_many :resource_control_fields, inverse_of: :resource_control
    has_many :queue_accesses, inverse_of: :resource_control
    accepts_nested_attributes_for :resource_control_fields, :queue_accesses,  allow_destroy: true
    validates :access, :status, :started_at, presence: true
    validates :queue_accesses, length: { minimum: 1 }

    string_enum %i[active blocked disabled]
    after_initialize({ if: :new_record? }) do |control|
      control.status ||= 'active'
    end

    def self.calculated
      where(status: %w[active blocked])
    end

    def self.calculate_resources
      calculated
        .includes(access: [{ project: %i[members removed_members] }, :cluster],
                  queue_accesses: :partition)
        .group_by { |r| r.access.cluster }
        .each do |cluster, controls|
          results = Core::NodeHourCounterService.new(cluster,
                                        controls.map(&:format_for_counter)).run
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
              control.block_or_activate!
            end
          end
      end
    end

    def self.send_emails_about_usage
      project_ids = calculated.select('DISTINCT core_accesses.project_id')
                              .joins(:access).map { |r| r['project_id'] }
      Core::Member.where(notify_about_resources: true, project_id: project_ids)
                  .each do |m|
       ::Core::MailerWorker.perform_async(:resource_usage, m.user_id, m.project_id)
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

    def block_or_activate!
      if exceeded?
        self.status = 'blocked'
        queue_accesses.each(&:block!)
      else
        self.status = 'active'
        queue_accesses.each(&:activate!)
      end
      save!
    end

    def disable!
      self.status = 'disabled'
      queue_accesses.each(&:block!)
      save!
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
  end
end
