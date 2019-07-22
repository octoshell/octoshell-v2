require_dependency "jobstat/application_controller"

module Jobstat
  class JobController < ApplicationController
    include JobHelper

    def graph_data_multi(dataset_a, dataset_b)
      tmp_hash = {}

      dataset_b.each do |entry|
        tmp_hash[entry.time] = entry.value
      end

      result = []

      dataset_a.each do |entry|
	      result.push([entry.time.to_i, entry.value, tmp_hash[entry.time]])
      end

      result
    end

    def graph_data_single dataset
      result = []

      dataset.each do |entry|
	      result.push([entry.time.to_i, entry.value])
      end

      result
    end

    def show
      @job = Job.find(params[:id])
      @jobs_plus={@job.drms_job_id => [:id, :cluster, :drms_job_id, :drms_task_id, :login, :partition, :submit_time, :start_time, :end_time, :timelimit, :command, :state, :num_cores, :num_nodes].map{|i| [i.to_s, @job[i]]}.to_h}
      @feedbacks=Job::get_feedback_job(params[:user].to_i, @job.id) || {}

      @job_perf = @job.get_performance
      @ranking = @job.get_ranking
      @current_user = current_user

      @extra_css='jobstat/application'
      @extra_js='jobstat/application'

      @cpu_digest_data = graph_data_single(DigestFloatDatum.where(job_id: @job.id, name: "cpu_user").order(:time).all)
      @gpu_digest_data = graph_data_single(DigestFloatDatum.where(job_id: @job.id, name: "gpu_load").order(:time).all)
      @loadavg_digest_data = graph_data_single(DigestFloatDatum.where(job_id: @job.id, name: "loadavg").order(:time).all)
#      @ipc_digest_data = graph_data_single(DigestFloatDatum.where(job_id: @job.id, name: "ipc").order(:time).all)

      rcv_mpi = DigestFloatDatum.where(job_id: @job.id, name: "ib_rcv_data_mpi").order(:time).all
      xmit_mpi = DigestFloatDatum.where(job_id: @job.id, name: "ib_xmit_data_mpi").order(:time).all

      rcv_fs = DigestFloatDatum.where(job_id: @job.id, name: "ib_rcv_data_fs").order(:time).all
      xmit_fs = DigestFloatDatum.where(job_id: @job.id, name: "ib_xmit_data_fs").order(:time).all

      @mpi_digest_data = graph_data_multi(rcv_mpi, xmit_mpi)
      @fs_digest_data = graph_data_multi(rcv_fs, xmit_fs)

      cpu_user = FloatDatum.where(job_id: @job.id, name: "cpu_user").take

      @agree_flags=Job.agree_flags
      @rules_plus=Job.rules
      #@filters=Job.get_filters(current_user).map { |x| x['filters'] }.flatten.uniq.reject{|x| x==''} # TODO:FILTERS
      @filters=[]

      # compile full rules descriptions
      @job_extra_data = @job.get_extra_data
      @job_rules_description = @job.get_rules(@current_user) + @job.get_detailed
      if @job_extra_data.present?
        @job_rules_description.each do |rule_descr|
          if @job_extra_data.key?(rule_descr['name'])
            replace_dict = @job_extra_data[rule_descr['name']]
            replace_dict.each do |key, value|
              rule_descr['description'].gsub! key, value
              rule_descr['supposition'].gsub! key, value
              rule_descr['text_recommendation'].gsub! key, value
            end
          end
        end
      end
      # end making rules description

      if cpu_user.nil? || cpu_user.value.nil?
        render :show_no_data
      end
    end

    def show_direct
      job = Job.where(drms_job_id: params["drms_job_id"], cluster: params["cluster"]).take
      redirect_to :action => 'show', :id => job.id
    end



    def detailed
      @detailed_info = Job.rules['detailed_analysis_types'][params[:analysis_id]]
      @analysis_id = params[:analysis_id]
      @job = Job.find(params[:id])
      if @detailed_info.nil?
          render :detailed_no_data
      end
    end

    def detailed_no_data
      
    end
  end
end
