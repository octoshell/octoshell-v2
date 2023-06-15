require 'main_spec_helper'
module Authentication
  RSpec.describe UsersController, type: :request do
    describe "POST create" do
      it "works without parameters passed" do
        post '/auth/users'
        expect(response.status).to eq(302)
      end

      it 'works with conditions accepted' do
        post '/auth/users', params: { cond: { cond_accepted: '1' } }
        expect(response.status).to eq(200)
      end

      it 'works with conditions accepted and empty user email' do
        post '/auth/users', params: { cond: { cond_accepted: '1' },
                                      user: {email: ''}}
        expect(response.status).to eq(200)
      end
    end
  end
end
