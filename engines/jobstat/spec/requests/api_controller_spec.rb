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
      post '/jobstat/job/info', params: job_attrs.to_json, headers: { HTTP_AUTHORIZATION: string }
      expect(response).to have_http_status(204)
    end
  end
end
