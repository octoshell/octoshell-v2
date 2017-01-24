require 'json'

require_dependency "jd/application_controller"

module Jd
  class JdController < ApplicationController
    @@host=""
    def get_job_info(job_id)
      url = @@host + "/api/jobs/#{job_id}/info"

      begin
        open(url) do |io|
          return JSON.parse(io.read)
        end
      rescue => exception
        return {}
      end
    end

    def get_job_performance(job_id)
      url = @@host + "/api/monitoring/jobs/#{job_id}/performance"

      begin
        open(url) do |io|
          return JSON.parse(io.read)
        end
      rescue => exception
        return {}
      end
    end

    def get_job_sensors(job_id, sensor)
      url = @@host + "/api/monitoring/jobs/#{job_id}/#{sensor}"

      begin
        open(url) do |io|
          return JSON.parse(io.read)
        end
      rescue => exception
        return {}
      end
    end

    def sensor()
      job_id = params[:job_id]
      sensor = params[:sensor]

      @info = get_job_info(job_id)

      if get_accounts().include? @info["account"]
        render :json => get_job_sensors(job_id, sensor)
      else
        raise MayMay::Unauthorized
      end
    end

    def show_job()
      job_id = params[:job_id]

      @info = get_job_info(job_id)
      @performance = get_job_performance(job_id)

      if get_accounts().include? @info["account"]
        render :show_job
      else
        raise MayMay::Unauthorized
      end
    end
  end
end
