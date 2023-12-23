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
      expect { post '/jobstat/job/info', params: job_attrs.to_json }.to raise_error('jobstat: invalid authenticate')
    end

    it 'updates job when password is given' do
      user = 'test'
      password = 'password'
      string = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
      Rails.application.secrets[:jobstat] = { user: user, password: password }
      expect { post '/jobstat/job/info', headers: { HTTP_AUTHORIZATION: string },
               params: job_attrs.to_json }.not_to raise_error
    end
  end
end
