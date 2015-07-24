module Core
  class Cluster < ActiveRecord::Base
    has_many :requests, inverse_of: :cluster, dependent: :destroy
    has_many :accesses, inverse_of: :cluster, dependent: :destroy
    has_many :projects, through: :accesses

    has_many :logs, class_name: "ClusterLog", inverse_of: :cluster, dependent: :destroy

    has_many :quotas, class_name: "ClusterQuota", inverse_of: :cluster, dependent: :destroy
    accepts_nested_attributes_for :quotas, allow_destroy: true

    validates :host, :admin_login, presence: true

    # state_machine initial: :active do
    #   state :active
    #   state :inactive

    #   event :deactivate do
    #     transition :active => :inactive
    #   end

    #   event :activate do
    #     transition :inactive => :active
    #   end

    #   after_transition :inactive => :active do |cluster, _|
    #     accesses.map(&:synchronize!)
    #   end
    # end

    def create_or_update
      generate_ssh_keys if new_record?
      super
    end

    def log(message, project)
      logs.create!(message: message, project: project)
    end

    def quotas_info
      quotas.map(&:to_s).join(" | ")
    end

    def to_s
      name
    end

    def generate_ssh_keys
      key = SSHKey.generate(:comment => host)
      self.public_key = key.ssh_public_key
      self.private_key = key.private_key
    end
  end
end
