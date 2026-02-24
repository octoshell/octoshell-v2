# == Schema Information
#
# Table name: core_accesses
#
#  id                 :integer          not null, primary key
#  project_group_name :string(255)
#  state              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  cluster_id         :integer          not null
#  project_id         :integer          not null
#
# Indexes
#
#  index_core_accesses_on_cluster_id                 (cluster_id)
#  index_core_accesses_on_project_id                 (project_id)
#  index_core_accesses_on_project_id_and_cluster_id  (project_id,cluster_id) UNIQUE
#

module Core
  class Access < ApplicationRecord
    belongs_to :project
    belongs_to :cluster

    has_many :fields, class_name: 'AccessField', inverse_of: :access, dependent: :destroy
    accepts_nested_attributes_for :fields
    validates :project, :cluster, presence: true
    has_many :resource_controls, inverse_of: :access
    has_many :resource_users, inverse_of: :access
    has_many :queue_accesses, inverse_of: :access
    has_many :uncontrolled_queue_accesses, -> { where(resource_control_id: nil) },
             inverse_of: :access,
             class_name: 'Core::QueueAccess'

    accepts_nested_attributes_for :resource_controls, :uncontrolled_queue_accesses,
                                  :resource_users, allow_destroy: true
    validate do
      next unless (uncontrolled_queue_accesses | resource_controls.map(&:queue_accesses).flatten).any? do |q|
        !q.new_record? && !q.synced_with_cluster && q.marked_for_destruction?
      end

      errors.add(:base, :not_synced)
    end

    def notify_about_resources
      resource_users.each do |r|
        ::Core::MailerWorker.perform_async(:resource_usage, r.id, id)
      end
    end

    include AASM
    include ::AASM_Additions
    aasm :state, column: :state do
      state :opened, initial: true
      state :closed

      event :close do
        transitions from: :opened, to: :closed
      end

      event :reopen do
        transitions from: :closed, to: :opened
      end
    end

    def quota_resources_info
      fields.map(&:to_s).join(' | ')
    end

    def log(message)
      logger.info message
    end

    def to_s
      "#{project.title} | #{cluster.name}"
    end

    def build_queue_accesses
      resource_controls.each do |control|
        control.build_resource_control_fields
        (cluster.partitions - control.queue_accesses.map(&:partition).flatten).each do |part|
          control.queue_accesses.new(partition: part, access_id: id).mark_for_destruction
        end
      end
      (cluster.partitions - uncontrolled_queue_accesses.map(&:partition).flatten).each do |part|
        uncontrolled_queue_accesses.new(partition: part).mark_for_destruction
      end
    end

    # Требования к теребоньке.
    #
    # Выполнять все действия в по одному ssh-соединению
    # логировать все команды и результаты выполнения
    # синхронизовать проект
    # синхронизовать участников проекта
    # для участников проекта закидывать ключи через scp

    def synchronize!
      Synchronizer.new(self).run!
    end
  end
end
