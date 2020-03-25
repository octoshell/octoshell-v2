require 'main_spec_helper'
module TestEngine
  extend Octoface
  module Admin
    class MainApplicationController < ApplicationController
      before_action :octo_authorize!
      def test
        render nothing: true, status: 200
      end
    end
  end
end
module Octoface

  describe Octoface do

    before(:each) do
      TestEngine.octo_configure do
        add(:funny_string) { 'string' }
        add_ability :manage, :test_engine, 'superadmins'
        OctoConfig.finalize!
      end
    end

    it "defines variable" do
      expect(TestEngine.funny_string).to eq 'string'
    end

    it "creates abilities" do
      expect(TestEngine.octo_config.abilities).to eq [[:manage, :test_engine, 'superadmins']]
    end

    # describe TestEngine::Admin::MainApplicationController, type: :controller do
    #   before(:each) do
    #     Octoshell::Application.routes.draw do
    #       get "random_folder/test" => "test_engine/admin/main#test"
    #     end
    #   end
    #   it "assigns @teams" do
    #     get :test
    #   end
    # end
  end
end
