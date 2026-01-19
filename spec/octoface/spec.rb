require 'main_spec_helper'
module TestEngine
  extend Octoface
  class Model
  end
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
      TestEngine.octo_configure :fake do
        add('Model')
        add_ability :manage, :test_engine, 'superadmins'
        OctoConfig.finalize!
      end
    end

    it "defines variable" do
      expect(Octoface.role_class(:fake, 'Model')).to eq TestEngine::Model
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
