require 'main_spec_helper'
module Jobstat
  describe ApiController, type: :request do
    let(:job_attrs) do
      { 'cluster' => 'cluster',
        'state' => 'RUNNING',
        'job_id' => 1,
        'task_id' => 1,
        'account' => 'account_fun',
        'partition' => 'compute' }
        .merge(%w[t_submit t_end t_start].map { |a| [a, Time.now.to_i] }.to_h)
    end

    it 'fails to update job when no password is given' do
      post '/jobstat/job/info', params: job_attrs.to_json
      expect(response).to have_http_status(401)
    end

    it 'updates job when password is given' do
      user = 'test'
      password = 'password'
      string = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
      post '/jobstat/job/info', params: job_attrs.to_json, headers: {
        HTTP_AUTHORIZATION: string,
        'CONTENT_TYPE' => 'application/json'
      }
      expect(response).to have_http_status(204)
    end
    it 'posts performance' do
      job = Job.create!({ 'cluster' => 'cluster',
                          'state' => 'RUNNING',
                          'drms_job_id' => 132,
                          'drms_task_id' => 0,
                          'login' => 'account',
                          'partition' => 'compute' }
                 .merge(%w[submit_time end_time start_time]
                      .map { |a| [a, DateTime.current] }.to_h))
      user = 'test'
      password = 'password'
      string = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)

      hash = { 'cluster' => 'cluster', 'task_id' => 0, 'job_id' => 132,
               'avg' => { 'instructions' => 610_595_928.5333333, 'cpu_user' => 46.45086735354529,
                          'ib_rcv_data_mpi' => 1_131_738.8733064227, 'ib_xmit_pckts_mpi' => 720.6826497395833,
                          'lustre_read_bytes' => 1_061_632.3444444444, 'lustre_write_bytes' => 1_817_158.6,
                          'gpu_load' => 0.3 } }
      post '/jobstat/job/performance', params: hash.to_json, headers: {
        HTTP_AUTHORIZATION: string,
        'CONTENT_TYPE' => 'application/json'
      }
      expect(response).to have_http_status(200)
    end
  end
end
