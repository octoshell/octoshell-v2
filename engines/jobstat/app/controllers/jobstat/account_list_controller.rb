require_dependency "jobstat/application_controller"

module Jobstat
  class AccountListController < ApplicationController
    include JobHelper

    #FEEDBACK_HOST = Rails.application.config.octo_feedback_host

    def index
      #@owned_logins = get_owned_logins
      #@involved_logins = get_involved_logins
      #
      # !!! FIXME   adding 'true' argument returns ALL available projects (for admins/experts)
      #             use it for admin version
      @projects=get_all_projects #{project: [login1,...], prj2: [log3,...]}
      @params = get_defaults.merge(params.symbolize_keys)
      @total_count = 0
      @shown = 0
      @js_cond=''
      @current_user=current_user

      @extra_css=['jobstat/application'] #, 'jobstat/introjs.min']
      @extra_js=['jobstat/application'] #, 'jobstat/intro.min']
      @jobs_feedback={}

      query_logins = @projects.map{|_,login| login}.flatten.uniq
      req_logins=(@params[:all_logins] || []).reject{|x| x==''}
      #!debug query_logins = ["vadim", "shvets", "vurdizm", "wasabiko", "ivanov", "afanasievily_251892", "gumerov_219059"]
      unless req_logins.include?('ALL') || req_logins.length==0
        query_logins = (req_logins & query_logins)
      end
      @params[:all_logins]=query_logins
      #@all_logins=get_select_options_by_projects @projects, query_logins
      @all_logins=get_grp_select_options_by_projects @projects, query_logins

      @rules_plus=Job.rules
      @jobs=[]
      @jobs_plus={}

      states=@params[:states].reject{|x| x==''}
      partitions=@params[:partitions].reject{|x| x==''}
      @params[:states]='ALL' if states.length==0
      @params[:partitions]='ALL' if partitions.length==0

      @agree_flags=Job.agree_flags

      begin
        # [{user: int, cluster: [string,...], account=[string,...], filters=[string,..]},....]
        @filters=Job::get_filters(current_user).map { |x|
          x['filters']
        }.flatten.uniq.reject{|x| x==''}
        # -> [cond1,cond2,...]

        @fake_data = params[:fake_data].to_i
        @start_intro = 0
        note=Core::Notice.where(sourceable: current_user, category: 2, message: 'intro:jobstat').take
        if note.nil?
          Core::Notice.create(sourceable: current_user, category: 2, message: 'intro:jobstat').save
          @start_intro = 1
          @fake_data = 10
        end

        params[:fake_data]=@fake_data
        if @fake_data!=0
          cluster=Core::Cluster.last
          now=DateTime.now
          j=OpenStruct.new(
            id: 1,
            cluster: cluster.name_en,
            drms_job_id: '1',
            drms_task_id: 0,
            login: 'my_login',
            partition: Core::Partition.where(cluster: cluster).last.name,
            submit_time: now-1,
            start_time: now-2/8r,
            end_time: now,
            timelimit: 1000000,
            command: "world_optimizer",
            state: "COMPLETED",
            num_cores: 256,
            num_nodes: 1,
            nodelist: "node-0001",
            get_duration_hours: 6,
            rules:{'rule_anomaly' => 'It seems to be hang...'},
            filtered: 0,
            get_performance: { cpu_user: 10, gpu_load: 20,
              loadavg: 15, ipc: 0.1, ib_rcv_data_mpi: 123000, ib_xmit_data_mpi: 123000,
            },
            get_ranking: {cpu_user: 'low', gpu_load: 'low', loadavg: 'average',
              ipc: 'average', ib_rcv_data_mpi: 'low', ib_xmit_data_mpi: 'low',
            }
          )
          @jobs=[j]
          @jobs << OpenStruct.new(
            id: 2,
            cluster: cluster.name_en,
            drms_job_id: '2',
            drms_task_id: 0,
            login: 'my_login',
            partition: Core::Partition.where(cluster: cluster).last.name,
            submit_time: now-7/8r,
            start_time: now-2/8r,
            end_time: now-1/8r,
            timelimit: 1000000,
            command: "optimized_world_optimizer",
            state: "COMPLETED",
            num_cores: 12800,
            num_nodes: 2000,
            nodelist: "node-[0002-2001]",
            get_duration_hours: 3,
            rules:{'rule_disbalance_cpu_la' => 'Заметный дисбаланс внутри узлов либо активность сильно отличается на разных узлах.',
                   'rule_cpu_gpu' => "Задача слабо использует CPU при высокой загрузке GPU."},
            filtered: 0,
            get_performance: { cpu_user: 1, gpu_load: 53,
              loadavg: 1.23, ipc: 0.01112, ib_rcv_data_mpi: 12112, ib_xmit_data_mpi: 12676,
            },
            get_ranking: {cpu_user: 'low', gpu_load: 'average', loadavg: 'low',
              ipc: 'low', ib_rcv_data_mpi: 'low', ib_xmit_data_mpi: 'low',
            }
          )

          #Job.where(drms_job_id: 869867)
          @total_count=2
          @jobs_plus['1']=j
          @jobs_feedback['1']={ }
          @jobs_plus['2']=@jobs[1]
          @jobs_feedback['2']={ }
        else
          @jobs = get_jobs(@params, query_logins)
          #logger.info "JOBS: #{@jobs}"
          @total_count = @jobs.count
          @jobs = @jobs.offset(params[:offset].to_i).limit(@PER_PAGE)

          @jobs.each{|j|
            rules=j.get_rules(@current_user)
            @jobs_plus[j.drms_job_id]={'rules'=>{},'filtered' => 0}
            rules.each{|r|
              @jobs_plus[j.drms_job_id]['rules'][r['name']] = r['description']
              @jobs_plus[j.drms_job_id]['filtered']+=1 if @filters.include? r['name']
            }
          }
        end
        @shown = @jobs.length
        @jobs=@jobs.to_a
      rescue => e
        logger.info "account_list_controller:index: #{e.message}; #{e.backtrace.join("\n")}"
        @jobs = []
      end

      joblist=@jobs.map{|j| j.drms_job_id}
      #logger.info "JOBLIST: #{joblist.inspect}"
      jobs_feedback=Job::get_feedback_job(params[:user].to_i, joblist) || {}
      #logger.info "JOBLIST got: #{jobs_feedback}"
      #[{user:int, cluster: string, job_id: int, task_id: int, class=int, feedback=string, condition=string},{...}]
      
      @jobs_feedback={}
      jobs_feedback.each { |f|
        @jobs_feedback[f['job_id']]||={}
        @jobs_feedback[f['job_id']][f['condition']]={
          user: f['user'], cluster: f['cluster'],
          task_id: f['task_id'], klass: f['class'], feedback: f['feedback']
        }
      }

      @jobs.each do |job|
        id=job['drms_job_id']
        @jobs_plus[id]||={}
        ['cluster', 'drms_job_id', 'drms_task_id', 'login', 'partition', 'submit_time', 'start_time', 'end_time',
         'timelimit', 'command', 'state', 'num_cores', 'num_nodes'].each{|i|
          @jobs_plus[id][i]=job[i]
        }
        @jobs_plus[id]['feedback']=if(@jobs_feedback.fetch(id,false))
          # there is a feedback!
          {'class' => @jobs_feedback[id][:klass]}
        else
          {}
        end
      end

      # FIXME!!!!!! (see all_rules)
      @emails = JobMailFilter.filters_for_user current_user.id

    end

    def feedback
      code=case params[:type]
      when 'feedback_rule_only'
        feedback_rule_only params[:feedback]    # ...
      when 'multi_jobs'
        feedback_multi_jobs params[:feedback]   # ok (jobs+rules disagree)
      when 'proposal'
        feedback_proposal params[:feedback]     # new rule
      when 'hide_rule'
        feedback_rule_show params[:feedback]    # hide one rule
      when 'feedback_rule'
        feedback_rule params[:feedback]         # ...
      when 'email_rule'
        email_rule params[:feedback]            #  enable/disable email notification for rules
      else
        logger.info "Bad feedback type: #{params[:type]}"
        500 #, "Bad feedback type: #{params[:type]}"
      end
      render plain: code, layout: false
    end

    def feedback_multi_jobs parm
      #"0"=>{"user"=>"1234", "cluster"=>"lomonosov-2", "job_id"=>"615023",
      #      "task_id"=>"0", "class"=>"0", "feedback"=>"ooops"},
      uri=URI("#{Rails.application.config.octo_feedback_host}/api/feedback-job")
      #user=UID_octoshell(int), class=int(0=ok,1=not_ok), cluster=string, job_id=int, task_id=int, condition=string, feedback=string.
      if !parm.kind_of?(Enumerable)
        logger.info("Ooooops! feedback_all_jobs got bad argument: #{parm}") 
        return 500,''
      end
      arr= (parm.kind_of?(Hash) ? parm.map{|k,v| v} : parm.map{|x| x})
      code=200
      arr.each do |job|
        resp=Job::post_data(uri,job)  
        unless Net::HTTPSuccess === resp
          logger.info "feedback_multi_jobs: post code=#{resp ? resp.code : -1}"
          code=500
        end
      end
    end

    def all_rules
      @extra_css='jobstat/application'
      @extra_js='jobstat/application'
      @rules_plus=Job.rules
      @filters=Job::get_filters(current_user).map { |x| x['filters'] }.flatten.uniq
      @current_user=current_user

      @emails = JobMailFilter.filters_for_user current_user.id
    end

    def feedback_proposal parm
      #http://graphit.parallel.ru:8123/api/feedback-proposal?user=1&cluster=lomonosov-2&job_id=585183&task_id=0&feedback=something-something
      uri=URI("#{Rails.application.config.octo_feedback_host}/api/feedback-proposal")

      req={
        user: parm[:user].to_i,
        #cluster: 'all',
        #account: parm['acount'],
        feedback: parm[:feedback],
      }
      [:cluster,:account].each do |x|
        req[x]=parm[x] if parm[x]
      end
      resp=Job::post_data(uri,req)
      if Net::HTTPSuccess === resp
        200
      else
        logger.info "feedback_proposal: post code=#{resp ? resp.code : -1}"
        500
      end
    end

    # enable/disable email notifications
    def email_rule parm
      email={
        user: parm[:user].to_i,
        condition: parm[:condition],
        del: parm[:delete]
      }
      #TODO implement storing user/condition pairs for disabled notifications
      if parm[:delete].to_i == 1
        JobMailFilter.del_mail_filter current_user, parm[:condition]
      else
        JobMailFilter.add_mail_filter current_user, parm[:condition]
      end
      200
    end

    # hide rule
    def feedback_rule_show parm
      #TODO make caching for not confirmed sends
      #FIXME! move address to config
      # POST: user=UID_octoshell(int), cluster=string(список через запятую), account=string(список через запятую), filters=string(имена тегов через запятую)

      cond=parm[:condition]
      if cond.to_s == ''
        return 500, 'bad condition (empty)'
      end
      uri=URI("#{Rails.application.config.octo_feedback_host}/api/filters")

      filters=Job::get_filters(current_user)
        .map { |x| x['filters'] }
        .flatten
        .uniq
      if parm[:delete].to_s=='1'
        filters.reject! {|x| x==cond}
      else
        filters.push cond
      end
      req={
        user: parm[:user].to_i,
        cluster: parm[:cluster] || 'all',
        filters: filters.join(','),
        account: parm[:account] || 'none',
        feedback: parm[:feedback],
      }
      logger.info "feedback_rule_show: REQ=#{req.inspect}"
      resp=Job::post_data uri,req
      CacheData.delete("jobstat:filters:#{parm[:user]}")
      if Net::HTTPSuccess === resp
        200
      else
        logger.info "feedback_rule_show: post code=#{resp ? resp.code : -1}"
        500
      end
    end

    # hide rule
    def feedback_rule parm
      #TODO make caching for not confirmed sends
      #FIXME! move address to config
      #  user=UID_octoshell(int), cluster=string(список через запятую), account=string(список через запятую), condition=string, feedback=string.

      uri=URI("#{Rails.application.config.octo_feedback_host}/api/feedback-job")
      req={
        user: parm[:user].to_i,
        cluster: parm[:cluster] || 'all',
        account: parm[:account] || 'none',
        mass: parm[:mass] || 0,
        :class => parm[:class] || 0,
        job_id: parm[:job_id] || 0,
        task_id: parm[:task_id] || 0,
        condition: parm[:condition],
        feedback: parm[:feedback],
      }
      [:cluster,:account].each do |x|
        req[x]=parm[x] if parm[x]
      end
      resp=Job::post_data uri, req
      CacheData.delete("jobstat:fedback_rule:#{parm[:user]}")
      if Net::HTTPSuccess === resp
        200
      else
        logger.info "feedback_rule: post code=#{resp ? resp.code : -1}"
        500
      end
    end

    def feedback_rule_only parm
      #TODO make caching for not confirmed sends

      uri=URI("#{Rails.application.config.octo_feedback_host}/api/feedback-condition")
      req={
        user: parm[:user].to_i,
        :class => parm[:class] || 0,
        condition: parm[:condition],
        feedback: parm[:feedback],
      }
      resp=Job::post_data uri, req
      CacheData.delete("jobstat:fedback_rule:#{parm[:user]}")
      if Net::HTTPSuccess === resp
        200
      else
        logger.info "feedback_rule_only: post code=#{resp ? resp.code : -1}"
        500
      end
    end

    protected

    def get_defaults
      {:start_time => Date.today.prev_day.beginning_of_month.strftime("%Y.%m.%d"),
       :end_time => Date.today.strftime("%Y.%m.%d"),
       :cluster => @default_cluster,
       :states => [],
       :partitions => [],
       :involved_logins => [],
       :owned_logins => [],
       :only_long => 1,
       :only_with_data => 0,
       :offset => 0
      }
    end

    def get_jobs(params, query_logins)
      jobs = Job.where "start_time > ? AND start_time < ?",
        DateTime.parse(params[:start_time]),
        DateTime.parse(params[:end_time])+1

      jobs = jobs.where(state: @params[:states]) unless params[:states].include?("ALL")
      jobs = jobs.where(partition: @params[:partitions]) unless params[:partitions].include?("ALL")

      if params[:only_long].to_i == 1
        jobs = jobs.where "end_time - start_time > '942 second'::interval" # 15:42 = 15*60+42
      end
      if params[:only_with_data].to_i == 1
        jobs = jobs.joins("inner join jobstat_float_data on jobstat_float_data.job_id=jobstat_jobs.id").where "jobstat_float_data.name='cpu_user'"
      end

      jobs.where(login: query_logins, cluster: params[:cluster])
        .order(:drms_job_id)
    end

  end
end
