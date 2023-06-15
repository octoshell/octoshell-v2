require 'main_spec_helper'
module Authentication
  RSpec.describe SessionsController, type: :request do
    describe "POST create" do
      it "works without parameters passed" do
        post '/auth/session'
        expect(response.status).to eq(200)
      end
    end
  end
end
