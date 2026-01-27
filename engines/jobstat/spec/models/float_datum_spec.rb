require 'main_spec_helper'
module Jobstat
  def self.create_job(attributes = {})
    Jobstat::Job.create!(FactoryBot.build(:job, attributes).attributes)
  end
  describe FloatDatum do
    describe '::save_job_perf' do
      it 'works' do
        job = Jobstat.create_job
        hash = { 'cluster' => 'lomonosov-2', 'task_id' => 0, 'job_id' => job.id,
                 'avg' => { 'instructions' => 610_595_928.5333333, 'cpu_user' => 46.45086735354529,
                            'ib_rcv_data_mpi' => 1_131_738.8733064227, 'ib_xmit_pckts_mpi' => 720.6826497395833,
                            'lustre_read_bytes' => 1_061_632.3444444444, 'lustre_write_bytes' => 1_817_158.6,
                            'gpu_load' => 0.3 } }
        Jobstat::FloatDatum.save_job_perf(job.id, hash)
        expect(FloatDatum.where(job_id: job.id, name: 'lustre_read_bytes').exists?).to eq true
      end
    end
  end
end
