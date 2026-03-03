# == Schema Information
#
# Table name: core_clusters
#
#  id                 :integer          not null, primary key
#  admin_login        :string(255)
#  available_for_work :boolean          default(TRUE)
#  description        :text
#  host               :string(255)      not null
#  name_en            :string
#  name_ru            :string(255)      not null
#  private_key        :text
#  public_key         :text
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_core_clusters_on_private_key  (private_key) UNIQUE
#  index_core_clusters_on_public_key   (public_key) UNIQUE
#

module Core
  class Cluster < ApplicationRecord
    translates :name

    has_many :requests, inverse_of: :cluster, dependent: :destroy
    has_many :accesses, inverse_of: :cluster, dependent: :destroy
    has_many :projects, through: :accesses

    has_many :partitions, inverse_of: :cluster, dependent: :destroy
    accepts_nested_attributes_for :partitions, allow_destroy: true

    has_many :logs, class_name: 'ClusterLog', inverse_of: :cluster, dependent: :destroy

    has_many :quotas, class_name: 'ClusterQuota', inverse_of: :cluster, dependent: :destroy
    accepts_nested_attributes_for :quotas, allow_destroy: true
    validates :host, :admin_login, presence: true
    validates_translated :name, presence: true
    scope :finder, lambda { |q|
      where("lower(#{current_locale_column(:name)}) like :q", q: "%#{q.mb_chars.downcase}%").order current_locale_column(:name)
    }

    before_create do
      generate_ssh_keys
    end

    def log(message, project)
      logs.create!(message: message, project: project)
    end

    def quotas_info
      quotas.map(&:to_s).join(' | ')
    end

    def to_s
      name
    end

    def as_json(_options = nil)
      { id: id, text: name }
    end

    def execute(command, ssh = nil)
      return exec!(ssh, command) if ssh

      Net::SSH.start(host, admin_login, key_data: private_key) do |ssh|
        exec!(ssh, command)
      end
    end

    private

    def generate_ssh_keys
      key = SSHKey.generate(comment: host)
      self.public_key = key.ssh_public_key
      self.private_key = key.private_key
    end

    def exec!(ssh, command)
      stdout_data = ''
      stderr_data = ''
      ssh.exec!(command) do |_channel, stream, data|
        case stream
        when :stdout
          stdout_data << data
        when :stderr
          stderr_data << data
        end
      end
      [stdout_data, stderr_data].map { |d| d.force_encoding('UTF-8') }
    end
  end
end
