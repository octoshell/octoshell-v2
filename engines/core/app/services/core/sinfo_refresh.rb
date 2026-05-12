module Core
  class SinfoRefresh
    Outcome = Struct.new(
      :ok?,
      :cluster_id,
      :snapshot_id,
      :nodes_total,
      :result,
      :error_class,
      :error_message,
      keyword_init: true
    )

    def self.call(
      cluster_id:,
      user_id: nil,
      cache: Rails.cache,
      ssh_key_path: nil,
      hpc_user_env: "HPC_USER",
      fallback_user: "papchenko30_2363"
    )
      new(
        cluster_id: cluster_id,
        user_id: user_id,
        cache: cache,
        ssh_key_path: ssh_key_path,
        hpc_user_env: hpc_user_env,
        fallback_user: fallback_user
      ).call
    end

    def initialize(cluster_id:, user_id:, cache:, ssh_key_path:, hpc_user_env:, fallback_user:)
      @cluster_id    = cluster_id.to_s.strip
      @user_id       = user_id
      @cache         = cache
      # @ssh_key_path  = File.expand_path(ssh_key_path.presence || "~/.ssh/id_ed25519")
      @hpc_user_env  = hpc_user_env
      @fallback_user = fallback_user
    end

    def call
      raise ArgumentError, "cluster_id is required" if @cluster_id.blank?

      cluster = Core::Cluster.find(@cluster_id)
      Rails.logger.info("[SINFO_REFRESH] cluster=#{cluster.id} host=#{cluster.host.inspect} admin_login=#{cluster.admin_login.inspect}")

      fetcher = Core::SinfoFetcher.new(
        host: cluster.host,
        user: cluster.admin_login,
        auth: { private_key_pem: cluster.private_key }
      )

      sinfo_log = fetcher.call.to_s
      Rails.logger.info("[SINFO_REFRESH] fetched #{sinfo_log.bytesize} bytes")

      raise sinfo_log if sinfo_log.start_with?("SSH error:")

      result = ActiveRecord::Base.transaction do
        Core::SinfoIngestor.new(
          raw_text: sinfo_log,
          source_cmd: "sinfo -a",
          parser_version: "v1",
          quiet: true,
          cluster_id: cluster.id
        ).call
      end

      Rails.logger.info("[SINFO_REFRESH] ingested result=#{result.inspect}")

      write_cache(:result, cluster.id, result)

      Outcome.new(
        ok?: true,
        cluster_id: cluster.id,
        snapshot_id: result[:snapshot_id],
        nodes_total: result[:nodes_total],
        result: result
      )
    rescue => e
      Rails.logger.error("[SINFO_REFRESH] error #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.first(15).join("\n"))

      cid = @cluster_id.presence || "none"
      write_cache(:error, cid, format_error(e))

      Outcome.new(
        ok?: false,
        cluster_id: cid,
        error_class: e.class.name,
        error_message: e.message
      )
    end

    private

    def write_cache(kind, cluster_id, payload)
      @cache.write(cache_key(kind, cluster_id), payload, expires_in: 10.minutes)
    end

    def cache_key(kind, cluster_id)
      uid = @user_id || "anon"
      "analytics:sinfo:cluster:#{cluster_id}:#{kind}:user:#{uid}"
    end

    def format_error(e)
      bt = Array(e.backtrace).take(20).join("\n")
      "#{e.class}: #{e.message}\n\n#{bt}"
    end
  end
end