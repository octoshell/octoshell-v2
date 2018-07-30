class CreateWikiTasks < ActiveRecord::Migration
  def change
    create_table :wiki_tasks do |t|
      t.string :account
      t.integer :task_id

      t.float :cores_hours
      t.string :workdir
      t.text :nodelist
      t.float :timelimit
      t.string :partition
      t.integer :num_cores
      t.datetime :t_start
      t.integer :num_nodes
      t.string :cluster
      t.string :state
      t.datetime :t_submit
      t.text :command
      t.float :duration
      t.datetime :t_end

      t.float :max_cpu_iowait
      t.float :max_ib_rcv_pckts
      t.float :max_cpu_soft_irq
      t.float :max_cpu_flops
      t.float :max_cpu_idle
      t.float :max_cpu_perf_l1d_repl
      t.float :max_cpu_user
      t.float :max_llc_miss
      t.float :max_ib_xmit_pckts
      t.float :max_mem_store
      t.float :max_loadavg
      t.float :max_ib_xmit_data
      t.float :max_cpu_irq
      t.float :max_cpu_nice
      t.float :max_ib_rcv_data
      t.float :max_cpu_system
      t.float :max_mem_load

      t.float :avg_cpu_iowait
      t.float :avg_ib_rcv_pckts
      t.float :avg_cpu_soft_irq
      t.float :avg_cpu_idle
      t.float :avg_cpu_perf_l1d_repl
      t.float :avg_cpu_user
      t.float :avg_llc_miss
      t.float :avg_ib_xmit_pckts
      t.float :avg_cpu_flops
      t.float :avg_loadavg
      t.float :avg_ib_xmit_data
      t.float :avg_cpu_irq
      t.float :avg_mem_store
      t.float :avg_cpu_nice
      t.float :avg_ib_rcv_data
      t.float :avg_cpu_system
      t.float :avg_mem_load

      t.float :min_cpu_iowait
      t.float :min_mem_store
      t.float :min_cpu_soft_irq
      t.float :min_cpu_idle
      t.float :min_ib_rcv_pckts
      t.float :min_cpu_flops
      t.float :min_cpu_perf_l1d_repl
      t.float :min_cpu_user
      t.float :min_llc_miss
      t.float :min_ib_xmit_pckts
      t.float :min_cpu_system
      t.float :min_loadavg
      t.float :min_ib_xmit_data
      t.float :min_cpu_irq
      t.float :min_cpu_nice
      t.float :min_ib_rcv_data
      t.float :min_mem_load

      t.timestamps null: false
    end
  end
end
