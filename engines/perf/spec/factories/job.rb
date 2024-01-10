FactoryBot.define do
  factory :job, class: 'Perf::Job' do
    sequence(:drms_job_id)
    sequence(:drms_task_id)
    end_time { DateTime.now }
    start_time { end_time - 3.hours }
    submit_time { end_time - 14.days }
    num_nodes { 2 }
    state { 'COMPLETED' }
    cluster { 'lomonosov-2' }
    # member { create(:member) }
  end
end
