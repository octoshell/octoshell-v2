require_dependency "jobstat/application_controller"

module Jobstat
  class AccountListController < ApplicationController
    include JobHelper

    PICTURES = {
      'rule_mpi_issues' => 'fas fa-exchange-alt', #Низкая активность использования вычислительных ресурсов при высокой интенсивности использования MPI сети.
      'rule_mpi_packets' => 'fas fa-exchange-alt', #Размер MPI пакетов слишком маленький.
      'rule_not_effective' => 'fas fa-dumbbell', #Низкая активность использования всех доступных ресурсов (процессоров, памяти, коммуникационной сети, графических ускорителей).
      'rule_bad_mem' => 'fas fa-memory', #Низкая активность использования вычислительных ресурсов при высокой интенсивности работы с памятью.
      'rule_bad_locality' => 'fas fa-bug', #Низкая активность работы задачи при низкой локальности обращений в память.
      'rule_locality' => 'fas fa-dice', #Высокая интенсивность работы с памятью при низкой локальности обращений в память.
      'rule_cache' => 'fas fa-dice', #Низкая активность работы задачи при высокой интенсивности работы с памятью и низкой локальности обращений в память.
      'rule_interleave' => 'fas fa-dice', #Низкая активность работы задачи при высокой интенсивности работы с памятью и высокой локальности обращений в память.
      'rule_normal_serial' => 'fas fa-thumbs-down', #Последовательная задача
      'rule_cpu_gpu' => 'fas fa-microchip', #Задача слабо использует CPU при высокой загрузке GPU. 
      'rule_more_cpu_gpu' => 'fas fa-microchip', #Задача практически не использует CPU при высокой загрузке GPU.
      'rule_anomaly' => 'fas fa-exclamation', #Чрезвычайно низкая активность использования всех доступных ресурсов.
      'rule_disbalance_cpu_la' => 'fas fa-not-equal', #Заметный дисбаланс внутри узлов либо активность сильно отличается на разных узлах.
      'rule_avg_disbalance' => 'fas fa-not-equal', #Интенсивность использования ресурсов сильно отличается на разных узлах.
      'rule_node_disbalance' => 'fas fa-not-equal', #Данные мониторинга сильно отличаются для разных узлов -> скорее всего, имеет место разбалансировка. Правило имеет смысл учитывать, если не сработали более конкретные правила
      'rule_mpi_many_operations' => 'fas fa-sync', #Низкая интенсивность использования MPI сети, однако число MPI операций велико.
      'rule_mpi_small_packets' => 'fas fa-angle-double-left', #Слишком маленькие средние размеры MPI IB пакетов при достаточно высокой интенсивности использования коммуникационной сети.
      'rule_fs_small_packets' => 'fas fa-save', #Слишком маленькие средние размеры ФС IB пакетов при достаточно высокой интенсивности использования коммуникационной сети.
      'rule_mpi_high_system' => 'fas fa-moon', #Работа с коммуникационнной сетью занимает слишком много системных ресурсов.
      'rule_mpi_bad_locality' => 'fas fa-random', #Задача активно работает с MPI сетью, но сетевая локальность плохая (узлы СК расположены далеко друг от друга).
      'rule_wrong_partition_gpu' => 'fas fa-bomb', #Задача запущена в разделе для GPU задач, однако практически не использует графические процессоры.
      'rule_wrong_partition_io' => 'fas fa-bomb', #Задача запущена в разделе для задач с невысокими требованиям к скорости вовода/вывода, однако в этой задаче интенсивность ввода/вывода велика.
      'rule_one_active_process' => 'fas fa-bolt', #В даной задаче обнаружен только 1 активный процесс на узел, при этом интенсивность использования памяти, GPU или сети невысока.
      'rule_mpi_disbalance' => 'fas fa-not-equal', #Большой дислабанс на узлах между средним объемом передаваемых и получаемых данных по MPI сети.
      'rule_irq_iowait' => 'fas fa-save', #Слишком высокая IRQ или IOWAIT загрузка.
      'rule_nice' => 'fas fa-snowflake', #Слишком высокая NICE загрузка.
      'rule_disaster' => 'fas fa-exclamation-triangle',
    }

    def index
      @owned_logins = get_owned_logins
      @involved_logins = get_involved_logins
      @params = get_defaults.merge(params.symbolize_keys)
      @total_count = 0
      @shown = 0
      @js_cond=''
      @current_user=current_user

      @extra_css='jobstat/application'
      @extra_js='jobstat/application'
      @pictures=PICTURES

      query_logins = (@params[:involved_logins] | @params[:owned_logins]) & (@involved_logins | @owned_logins)

      if @params[:states].length == 0 or
          @params[:partitions].length == 0 or
          query_logins.length == 0

        @notice = "Choose all query parameters"
        return
      else
        @notice = nil
      end

      begin
        @jobs = get_jobs(@params, query_logins)
        @total_count = @jobs.count
        @jobs = @jobs.offset(params[:offset].to_i).limit(@PER_PAGE)
        @shown = @jobs.length

        @jobs_plus={}

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

      @agree_flags={
        0 => 'far fa-thumbs-up agreed-flag',
        1 => 'far fa-thumbs-down agreed-flag',
        99 => 'far fa-clock agreed-flag',
      }

      # [{user: int, cluster: [string,...], account=[string,...], filters=[string,..]},....]
      @filters=Job::get_filters(current_user).map { |x| x.filters }.flatten.uniq
      # -> [cond1,cond2,...]
    end

    # def get_feedback_job(user,jobs)
    #   code=Job::get_feedback_job(params[:user].to_i, jobs)
    #   render plain: code, layout: false
    #   response.status=code
    # end

    def feedback
      code=case params[:type]
      when 'one_job'
        feedback_job params[:feedback]
      when 'multi_jobs'
        feedback_multi_jobs params[:feedback]
      when 'proposal'
        feedback_proposal params[:feedback]
      when 'hide_rule'
        feedback_rule_show params[:feedback]
      when 'feedback_rule'
        feedback_rule params[:feedback]
      else
        logger.info "Bad feedback type: #{params[:type]}"
        500
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
        return 500
      end
      arr= (parm.kind_of?(Hash) ? parm.map{|k,v| v} : parm.map{|x| x})
      #logger.info("--->> #{arr}")
      code=Job::post_data(uri,'',arr)
      if code!=200
        logger.info "feedback_all_jobs: post code=#{code}"
        500
      else
        200
      end
    end

    def feedback_job parm
      old_filters=Job::get_filters(current_user) || []
      new_filters=parm[:filters] || []
      code=Job::post_filters(parm[:user].to_i, old_filters+new_filters)
      render plain: code, layout: false
      response.status=code
    end

    def feedback_jobs parm
      #TODO make caching for not confirmed sends
      #FIXME! move address to config
      uri=URI("http://graphit.parallel.ru:8123/api/feedback-jobs")

      jobs=parm[:jobs].split(',')
      req={
        user: parm[:user].to_i,
        cluster: parm[:cluster],
        jobs: jobs,
        tasks: jobs,
        feedback: parm[:feedback],
      }
      code=500
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
          #request.basic_auth 'username', 'password'

          resp = http.request request

          code=resp.code
        end
      rescue => e #Net::ReadTimeout, Net::OpenTimeout
        logger.info "feedback_job: error #{e.message}"
        code=500
      end
      render plain: code, layout: false
      response.status=code
    end

    # hide rule
    def feedback_rule_show parm
      #TODO make caching for not confirmed sends
      #FIXME! move address to config
      # POST: user=UID_octoshell(int), cluster=string(список через запятую), account=string(список через запятую), filters=string(имена тегов через запятую)

      uri=URI("http://graphit.parallel.ru:8123/api/filter")
      req={
        user: parm[:user].to_i,
        cluster: parm[:cluster],
        condition: parm[:condition],
        account: parm[:account],
      }
      code=500
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
          #request.basic_auth 'username', 'password'

          resp = http.request request

          code=resp.code
        end
        CacheData.delete("jobstat:filters:#{parm[:user]}")
      rescue => e #Net::ReadTimeout, Net::OpenTimeout
        logger.info "feedback_job: error #{e.message}"
        code=500
      end
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
      code=500
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
          #request.basic_auth 'username', 'password'

          resp = http.request request

          code=resp.code
        end
      rescue => e #Net::ReadTimeout, Net::OpenTimeout
        logger.info "feedback_rule: error #{e.message}"
        code=500
      end
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

  end
end
