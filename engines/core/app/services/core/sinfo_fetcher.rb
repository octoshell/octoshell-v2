require "net/ssh"
require "tempfile"

module Core
  class SinfoFetcher
    DEFAULT_CMD = "bash -lc 'module add slurm && sinfo -a'".freeze

    def initialize(cluster: nil, cluster_id: nil, host: nil, user: nil, auth: {}, cmd: DEFAULT_CMD)
      @cluster =
        cluster ||
        (cluster_id ? Core::Cluster.find(cluster_id) : nil)

      @host = host || @cluster&.host
      @user = user || @cluster&.admin_login
      @auth = auth
      @cmd  = cmd

      if @cluster && @auth.empty?
        if @cluster.private_key.present?
          @auth = { private_key_pem: @cluster.private_key }
        end
      end
    end

    def call
      raise ArgumentError, "host is required" if @host.blank?
      raise ArgumentError, "user is required" if @user.blank?

      ssh_opts = {
        non_interactive: true,
        number_of_password_prompts: 0,
        timeout: 20,
        keepalive: true,
        keepalive_interval: 15,
        verify_host_key: :never
      }

      key_tempfile = nil

      if @auth[:forward_agent]
        ssh_opts[:forward_agent] = true
      elsif @auth[:private_key_pem].present?
        key_tempfile = write_temp_key(@auth[:private_key_pem])
        ssh_opts[:keys] = [key_tempfile.path]
      elsif @auth[:key_path].present?
        ssh_opts[:keys] = [@auth[:key_path]]
      end

      Net::SSH.start(@host, @user, ssh_opts) do |ssh|
        stdout = ssh.exec!(@cmd)
        stdout.presence || "(пустой вывод)"
      end
    rescue => e
      "SSH error: #{e.class}: #{e.message}"
    ensure
      key_tempfile&.close
      key_tempfile&.unlink
    end

    private

    def write_temp_key(pem)
      tf = Tempfile.new(["octo-ssh-key", ""])
      tf.binmode
      tf.write(pem)
      tf.flush
      File.chmod(0o600, tf.path)
      tf
    end
  end
end
