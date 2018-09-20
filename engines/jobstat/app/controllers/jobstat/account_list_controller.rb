require_dependency "jobstat/application_controller"

module Jobstat
  class AccountListController < ApplicationController
    include JobHelper

    def index
      #@owned_logins = get_owned_logins
      #@involved_logins = get_involved_logins
      @projects=get_all_projects #{project: [login1,...], prj2: [log3,...]}
      @all_logins=get_select_options_by_projects @projects
      @params = get_defaults.merge(params.symbolize_keys)
      @total_count = 0
      @shown = 0
      @js_cond=''
      @current_user=current_user

      @extra_css='jobstat/application'
      @extra_js='jobstat/application'
      #@pictures=PICTURES
      @jobs_feedback={}

      #query_logins = (@params[:involved_logins] | @params[:owned_logins]) & (@involved_logins | @owned_logins)
      query_logins = @projects.map{|_,login| login}.uniq
      query_logins = ["vadim", "shvets", "vurdizm", "wasabiko", "ivanov", "afanasievily_251892", "gumerov_219059"]
      al=(@params[:all_logins] || []).reject{|x| x==''}
      query_logins = (al & query_logins)
      @params[:all_logins]=al

      @rules_plus=load_rules
      @jobs=[]
      @jobs_plus={}

      states=@params[:states].reject{|x| x==''}
      partitions=@params[:states].reject{|x| x==''}
      if states.length == 0 or
         partitions.length == 0 #or
          #query_logins.length == 0

        @notice = "Choose all query parameters"
        return
      else
        @notice = nil
      end

      @agree_flags={
        0 => 'far fa-thumbs-up agreed-flag',
        1 => 'far fa-thumbs-down agreed-flag',
        99 => 'far fa-clock agreed-flag',
      }

      begin
        @jobs = get_jobs(@params, query_logins)
        @total_count = @jobs.count
        @jobs = @jobs.offset(params[:offset].to_i).limit(@PER_PAGE)
        @shown = @jobs.length

        @jobs.each{|j|
          rules=j.get_rules(@current_user)
          @jobs_plus[j.drms_job_id]={'rules'=>{}}
          rules.each{|r|
            @jobs_plus[j.drms_job_id]['rules'][r.name] = r.description
          }
        }
      rescue => e
        logger.info "account_list_controller:index: #{e.message}; #{e.backtrace.join("\n")}"
        @jobs = []
      end

      jobs_feedback=Job::get_feedback_job(params[:user].to_i, @jobs) || {}
      #[{user:int, cluster: string, job_id: int, task_id: int, class=int, feedback=string, condition=string},{...}]
      
      @jobs_feedback={}
      jobs_feedback.each { |f|
        @jobs_feedback[f['job_id']]||={}
        @jobs_feedback[f['job_id']][f['condition']]={
          user:f['user'], cluster: f['cluster'],
          task_id:f['task_id'], klass:f['class'], feedback:f['feedback']
        }
      }

      @jobs.each do |job|
        id=job['drms_job_id']
        @jobs_plus[id]||={}
        ['cluster', 'drms_job_id', 'drms_task_id', 'login', 'partition', 'submit_time', 'start_time', 'end_time',
         'timelimit', 'command', 'state', 'num_cores', 'created_at', 'updated_at', 'num_nodes'].each{|i|
          @jobs_plus[id][i]=job[i]
        }
        @jobs_plus[id]['feedback']=if(@jobs_feedback.fetch(id,false))
          # there is a feedback!
          {'class' => @jobs_feedback[id][:klass]}
        else
          {}
        end
      end

      # [{user: int, cluster: [string,...], account=[string,...], filters=[string,..]},....]
      @filters=Job::get_filters(current_user).map { |x| x.filters }.flatten.uniq
      # -> [cond1,cond2,...]

      # FIXME!!!!!! (see all_rules)
      @emails = ["rule_avg_disbalance"]
    end

    # def get_feedback_job(user,jobs)
    #   code=Job::get_feedback_job(params[:user].to_i, jobs)
    #   render plain: code, layout: false
    #   response.status=code
    # end

    def feedback
      code=case params[:type]
      # when 'filter'
      #   feedback_filter params[:feedback]       # ...
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
      uri=URI("http://graphit.parallel.ru:8123/api/feedback-jobs")
      #user=UID_octoshell(int), class=int(0=ok,1=not_ok), cluster=string, job_id=int, task_id=int, condition=string, feedback=string.
      if !parm.kind_of?(Enumerable)
        logger.info("Ooooops! feedback_all_jobs got bad argument: #{parm}") 
        return 500,''
      end
      arr= (parm.kind_of?(Hash) ? parm.map{|k,v| v} : parm.map{|x| x})
      #logger.info("--->> #{arr}")
      code=Job::post_data(uri,'',arr)
      if code!=200
        logger.info "feedback_all_jobs: post code=#{code}"
        code=500
      end
      return code, "feedback_all_jobs: post code=#{code}"
    end

    def all_rules
      @extra_css='jobstat/application'
      @extra_js='jobstat/application'
      @rules_plus=load_rules
      @filters=Job::get_filters(current_user).map { |x| x.filters }.flatten.uniq
      @current_user=current_user

      # FIXME!!! just for tests!
      @emails = ["rule_avg_disbalance"]
    end

    def feedback_proposal parm
      #http://graphit.parallel.ru:8123/api/feedback-proposal?user=1&cluster=lomonosov-2&job_id=585183&task_id=0&feedback=something-something
      uri=URI("http://graphit.parallel.ru:8123/api/feedback-proposal")

      req={
        user: parm[:user].to_i,
        cluster: 'all',
        job_id: 0,
        tasks: 0,
        feedback: parm[:feedback],
      }
      code,body=post_feedback(uri,req)
      code
    end

    # enable/disable email notifications
    def email_rule parm
      email={
        user: parm[:user].to_i,
        condition: parm[:condition],
        del: parm[:delete]
      }
      #TODO implement storing user/condition pairs for disabled notifications
      logger.info "!!!!!!!!!!!!! NOT IMPLEMENTED YET: #{email}"
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
      uri=URI("http://graphit.parallel.ru:8123/api/filter")

      filters=Job::get_filters(current_user)
        .map { |x| x.filters }
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
        condition: filters.join(','),
        account: parm[:account],
      }
      logger.info "feedback_rule_show: REQ=#{req.inspect}"
      code,body=post_feedback uri,req
      CacheData.delete("jobstat:filters:#{parm[:user]}")
      code
    end

    # hide rule
    def feedback_rule parm
      #TODO make caching for not confirmed sends
      #FIXME! move address to config
      #  user=UID_octoshell(int), cluster=string(список через запятую), account=string(список через запятую), condition=string, feedback=string.

      uri=URI("http://graphit.parallel.ru:8123/api/feedback-condition")
      req={
        user: parm[:user].to_i,
        cluster: parm[:cluster],
        account: parm[:account],
        condition: parm[:condition],
        feedback: parm[:feedback],
      }
      code,body=post_feedback uri, req
      code
    end

    protected

    def get_defaults
      {:start_time => Date.today.beginning_of_month.strftime("%d.%m.%Y"),
       :end_time => Date.today.strftime("%d.%m.%Y"),
       :cluster => @default_cluster,
       :states => [],
       :partitions => [],
       :involved_logins => [],
       :owned_logins => [],
       :only_long => 1,
       :offset => 0
      }
    end

    def get_jobs(params, query_logins)
      jobs = Job.where "start_time > ? AND end_time < ?",
        DateTime.parse(params[:start_time]),
        DateTime.parse(params[:end_time])

      jobs = jobs.where(state: @params[:states]) unless params[:states].include?("ALL")
      jobs = jobs.where(partition: @params[:partitions]) unless params[:partitions].include?("ALL")

      if params[:only_long].to_i == 1
        jobs = jobs.where "end_time - start_time > 15 * '1 min'::interval"
      end

      jobs.where(login: query_logins, cluster: params[:cluster])
        .order(:drms_job_id)
    end

    def load_rules
      rules={}
      begin
        File.open("engines/jobstat/config/rules-plus.json", "r") { |file|
          rules=JSON.load(file)
        }
      rescue
      end
      rules
    end

    def post_feedback uri, req, user=nil, password=nil
      code=500
      resp=nil
      begin
        Net::HTTP.start(uri.host, uri.port,
                        :use_ssl => uri.scheme == 'https', 
                        :verify_mode => OpenSSL::SSL::VERIFY_NONE,
                        :read_timeout => 5,
                        :opent_imeout => 5,
                        :ssl_timeout => 5,
                       ) do |http|
          request = Net::HTTP::Post.new uri.request_uri
          request.set_form_data req
          if user
            request.basic_auth user, password.to_s
          end
          logger.info "post_feedback (#{uri})-> #{req.inspect}"
          resp = http.request request

          code=resp.code
        end
      rescue => e #Net::ReadTimeout, Net::OpenTimeout
        logger.info "post_feedback #{uri}: error #{e.message}"
        code=500
      end
      #render plain: code, layout: false
      #response.status=code
      return code
    end
  end
end
