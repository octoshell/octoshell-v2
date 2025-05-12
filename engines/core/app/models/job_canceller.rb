class JobCanceller
  attr_reader :connection_to_cluster, :cluster

  def initialize(cluster)
    @cluster = cluster
    @connection_to_cluster = establish_connection
  end

  def self.cancel_job_by_job_id(job_id)
    job = Jobstat::Job.find_by(id: job_id)
    unless job
      Rails.logger.error("Job not found with ID: #{job_id}")
      return
    end

    cluster_name = job.cluster
    unless cluster_name
      Rails.logger.error("Cluster name not found for job ID: #{job_id}")
      return
    end

    cluster = Core::Cluster.find_by(name_ru: cluster_name)
    unless cluster
      Rails.logger.error("Cluster not found with name: #{cluster_name}")
      return
    end

    job_canceller = new(cluster)
    job_canceller.cancel_job(job.drms_job_id)
  end

  def cancel_job(job_id)
    return unless connection_to_cluster

    command = "scancel #{job_id}"
    result = run_on_cluster(command)

    Rails.logger.warn "result: #{result}"

    if result.include?("invalid job id")
      Rails.logger.warn "Failed to cancel job #{job_id}: Invalid job ID"
    else
      Rails.logger.warn "Successfully cancelled job #{job_id}"
    end
  rescue => e
    Rails.logger.warn "Error cancelling job #{job_id}: #{e.message}"
  ensure
    connection_to_cluster.close if connection_to_cluster
  end

  private

  def establish_connection
    Net::SSH.start(@cluster.host,
                   @cluster.admin_login,
                   keys: [mock_ssh_key_path(@cluster.private_key)])
  rescue => e
    Rails.logger.warn "JobCanceller error: #{e.message}."
    nil
  end

  def mock_ssh_key_path(key)
    path = "/tmp/octo-#{SecureRandom.hex}"
    File.delete(path) if File.exist?(path)
    File.open(path, "wb", 0o600) { |f| f.write(key) }
    path
  end

  def run_on_cluster(command)
    if connection_to_cluster
      connection_to_cluster.exec!(command)
    else
      'Failed to connect cluster'
    end
  end
end
