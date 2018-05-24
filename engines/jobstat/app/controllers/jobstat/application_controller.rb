module Jobstat
  class ApplicationController < ActionController::Base
    layout "layouts/application"

    def not_authenticated
      redirect_to main_app.root_path, alert: t("flash.not_logged_in")
    end

    def not_authorized
      redirect_to main_app.root_path, alert: t("flash.not_authorized")
    end

    def get_owned_projects(user)
      # get hash with projects and logins for user
      # include all logins from owned projects

      result = Hash.new {|hash, key| hash[key] = []}

      user.owned_projects.each do |project|
        project.members.each do |member|
          result[project].push(member.login)
        end
      end

      result
    end

    def get_involved_projects(user)
      # get hash with projects and logins for user
      # include all personal logins for projects, where user is involved

      result = Hash.new {|hash, key| hash[key] = []}

      projects_with_participation = user.projects.where.not(id: (user.owned_projects.pluck(:id) \
         | user.projects_with_invitation.pluck(:id))) # TODO ???

      projects_with_participation.each do |project|
        project.members.each do |member|
          if member.user_id == user.id
            result[project].push(member.login)
          end
        end
      end

      result
    end

    def fill_owned_logins
      @owned_projects = get_owned_projects(current_user)

      @owned_logins = @owned_projects.map {|_, value| value}.uniq
      @owned_logins = ["vadim", "shvets", "vurdizm", "wasabiko", "ivanov", "afanasievily_251892", "gumerov_219059"]

    end

    def fill_involved_logins
      get_involved_projects = get_involved_projects(current_user)
      @involved_logins = get_involved_projects.map {|_, value| value}.uniq
      @involved_logins = ["vadim", "shvets", "vurdizm", "wasabiko", "ivanov", "afanasievily_251892", "gumerov_219059"]
    end


   @@thresholds_conditions = {
      "thr_high_loadavg" => "LoadAVG > 21",
      "thr_low_loadavg" => "LoadAVG < 4",
      "thr_high_cpu_user" => "CPU user load > 80%",
      "thr_low_cpu_user" => "CPU user load < 10%",
      "thr_high_cpu_system" => "CPU system load > 50%",
      "thr_low_cpu_system" => "CPU system load < 10%",
      "thr_high_cpu_irq" => "CPU irq load > 10%",
      "thr_low_cpu_irq" => "CPU irq load < 1%",
      "thr_high_cpu_nice" => "CPU nice load > 10%",
      "thr_low_cpu_nice" => "CPU nice load < 1%",
      "thr_high_cpu_iowait" => "CPU IO wait > 10%",
      "thr_low_cpu_iowait" => "CPU IO wait < 1%",
      "thr_high_gpu_load" => "GPU load > 80%",
      "thr_low_gpu_load" => "GPU load < 10%",
      "thr_high_ib_mpi" => "MPI IB speed > 5 * 10 ** 8 B/s",
      "thr_low_ib_mpi" => "MPI IB speed < 1.0 * 10 ** 4 B/s",
      "thr_high_ib_fs" => "FS IB speed > 5 * 10 ** 8 B/s",
      "thr_low_ib_fs" => "FS IB speed  < 1.0 * 10 ** 4 B/s",
      "thr_high_ib" => "High MPI IB speed and high FS IB speed",
      "thr_low_ib" => "Low MPI IB speed and low FS IB speed",
      "thr_high_mem_load" => "mem load >  7 * 10 ** 8 B/s",
      "thr_low_mem_load" => "mem load <  1 * 10 ** 8 B/s",
      "thr_high_mem_store" => "mem store > 2.5 * 10 ** 8 B/s",
      "thr_low_mem_store" => "mem store < 0.5 * 10 ** 8 B/s",
      "thr_high_l1_cache_miss" => "l1 miss > 5 * 10 ** 7 misses/s",
      "thr_low_l1_cache_miss" => "l1 miss < 5 * 10 ** 6 misses/s",
      "thr_high_l2_cache_miss" => "l2 miss > 2.5 * 10 ** 7 misses/s",
      "thr_low_l2_cache_miss" => "l2 miss < 3 * 10 ** 6 misses/s",
      "thr_high_llc_cache_miss" => "llc miss > 2 * 10 ** 6 misses/s",
      "thr_low_llc_cache_miss" => "llc miss < 1 * 10 ** 3 misses/s",
      "thr_high_network_locality" => "network locality > 5",
      "thr_low_network_locality" => "network locality < 2",
    }

    def get_thresholds_conditions(job)
      job.get_tags() & @@thresholds_conditions.keys
    end

    @@primary_conditions = 
    {
      "tag_short" => "Короткая задача (< 15 минут)",
      "tag_suspicious" => "Задача практически не использует вычислительные ресурсы СК",
      "tag_sc_appropriate" => "Задача хорошо использует ресурсы СК",
      "tag_less_suspicious" => "Задача слабо использует вычислительные ресурсы СК",
      "tag_comm_data" => "В задаче много MPI коммуникаций",
      "tag_comm_packets" => "Задача шлёт много MPI пакетов",
      "tag_not_comm" => "В задаче мало MPI коммуникаций",
      "tag_serial" => "Одноядерная задача",
      "tag_data_intensive" => "Задача активно работает с памятью",
      "tag_gpu_pure" => "Задача использует только GPU",
      "tag_gpu_hybrid_good" => "Задача хорошо испольует и GPU и CPU",
      "tag_single" => "Одноузловая задача",
      "tag_good_locality" => "Задача имеет высокую локальность обращений в память",
      "tag_bad_locality" => "Задача имеет низкую локальность обращений в память",
      "tag_weird_locality" => "Задача имеет необычную локальность обращений в память",
      "tag_low_ib_high_gpu" => "Задача активно испольузет GPU, а узлы мало общаются между собой",
    }

    def get_primary_conditions(job)
      job.get_tags() & @@primary_conditions.keys
    end

    @@smart_conditions = 
    {
      "rule_mpi_issues" => ["Низкая активность использования вычислительных ресурсов при высокой интенсивности использования MPI сети", "Выполнение MPI операций, вероятно, занимает слишком много времени, требуется оптимизация.","Анализ MPI программ -> Профилировка"],
      "rule_mpi_packets" => ["Размер MPI пакетов слишком маленький", "Накладные расходы на передачу MPI сообщений могут быть существенными.","Анализ MPI программ -> Профилировка"],
      "rule_disaster" => ["Низкая активность использования всех доступных ресурсов", "Причина низкой эффективности не обнаружена, требуется общий анализ.","1) Анализ динамики выполнения приложения;
        2) Общий анализ последовательных программ (если нет MPI);
        3) Анализ MPI -> Профилировка (если MPI есть)."],
      "rule_bad_mem" => ["Низкая активность использования вычислительных ресурсов при высокой интенсивности работы с памятью", "Работы с памятью, вероятно, занимает слишком много времени, требуется оптимизация.","Анализ работы с памятью -> Эффективность"],
      "rule_bad_locality" => ["Низкая активность работы задачи при низкой локальности обращений в память", "Работы с памятью, вероятно, организована неэффективно, требуется оптимизация.","Анализ работы с памятью -> Эффективность"],
      "rule_locality" => ["Высокая интенсивность работы с памятью при низкой локальности обращений в память", "Работы с памятью, вероятно, организована неэффективно, требуется оптимизация.","Анализ работы с памятью -> Эффективность"],
      "rule_cache" => ["Низкая активность работы задачи при высокой интенсивности работы с памятью и низкой локальности обращений в память", "Работы с памятью, вероятно, занимает слишком много времени и организована неэффективно, требуется оптимизация.","Анализ работы с памятью -> Эффективность"],
      "rule_interleave" => ["Низкая активность работы задачи при высокой интенсивности работы с памятью и высокой локальности обращений в память", "Работы с памятью занимает слишком много времени, но организована эффективно. Можно попробовать совмещать обработку данных с остальной работой в задаче (передачей данных или выполнением вычислений).","1) Анализ работы с памятью -> Эффективность»;
        2) Статический анализ."],
      "rule_cloud" => ["Последовательная задача", "Для работы на суперкомпьютере стоит распараллелить данную задачу.","Общий анализ последовательных программ "],
      "rule_cpu_gpu" => ["Задача слабо использует CPU при высокой загрузке GPU", "Можно попробовать одновременно загружать и CPU, и GPU.","Анализ работы с ускорителями"],
      "rule_more_cpu_gpu" => ["Задача практически не использует CPU при высокой загрузке GPU", "Можно попробовать одновременно загружать и CPU, и GPU.","Анализ работы с ускорителями"],
      "rule_anomaly" => ["Чрезвычайно низкая активность использования всех доступных ресурсов", "Задача работает некорректно или зависла. Рекомендуется проверить корректность запуска и при необходимости отменить его.","---"],
      "rule_disbalance_la" => ["Число активных процессов сильно отличается на разных узлах", "Разбалансировка нагрузки между узлами.","1) Анализ динамики выполнения приложения;
        2) Общий анализ последовательных программ (если нет MPI);
        3) Анализ MPI -> Профилировка (если MPI есть)."],
      "rule_mpi_small_packets" => ["Слишком маленькие средние размеры IB пакетов при достаточно высокой интенсивности использования коммуникационной сети", "Накладные расходы на передачу MPI сообщений могут быть существенными.","1) Анализ MPI программ -> Профилировка (если проблема с MPI сетью);
        2) Анализ ввода/вывода (если проблема с сетью для ФС)."],
      "rule_mpi_high_system" => ["Работа с коммуникационнной сетью занимает слишком много системных ресурсов", "Вероятно, работа с MPI сетью или сетью для ФС организована неэффективно.","1) Анализ MPI программ -> Профилировка (если проблема с MPI сетью);
        2) Анализ ввода/вывода (если проблема с сетью для ФС)."],
      "rule_mpi_bad_locality" => ["Задача активно работает с MPI сетью, но сетевая локальность плохая (узлы СК расположены далеко друг от друга)", "При запуске задачи менеджером ресурсов был выбран неудачный набор узлов. Рекомендуется при необходимости явно указывать узлы, на которых будет производиться запуск проргаммы, либо пытаться оптимизировать работу с MPI.","Анализ MPI программ -> Профилировка"],
      "rule_wrong_partition_gpu" => ["Задача запущена в разделе для GPU задач, однако практически не использует графические процессоры", "Неправильно выбран раздел для задачи. Рекомендуется сменить раздел.","---"],
      "rule_wrong_partition_io" => ["Задача запущена в разделе для задач с невысокими требованиям к скорости вовода/вывода, однако в этой задаче интенсивность ввода/вывода велика", "Неправильно выбран раздел для задачи. Рекомендуется сменить раздел.","---"],
      "rule_one_active_process" => ["В даной задаче обнаружен только 1 активный процесс на узел, при этом интенсивность использования памяти, GPU или сети невысока", "Вероятно, при запуске задачи указывается размещение 1 процесса на узел. Рекомендуется запускать с большим числом процессов на узел.","---"],
      "rule_mpi_disbalance" => ["Большой дислабанс на узлах между средним объемом передаваемых и получаемых данных по MPI сети", "Вероятно, некорректное использование MPI.","Анализ MPI программ -> Профилировка"],
      "rule_irq_iowait" => ["Слишком высокая IRQ или IOWAIT загрузка", "Вероятно, некорректный режим работы задачи","---"],
      "rule_nice" => ["Слишком высокая NICE загрузка", "Используются процессы с низким приоритетом. Рекомендуется перезапустить задачу с нормальным приоритетом.","---"],
    }

    def get_smart_conditions(job)
      job.get_tags() & @@smart_conditions.keys
    end

    helper_method :get_thresholds_conditions
    helper_method :get_primary_conditions
    helper_method :get_smart_conditions


  end
end
