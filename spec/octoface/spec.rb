require 'main_spec_helper'
module Octoface
  module TestEngine
    extend Octoface
  end
  describe Octoface do
    it "defines variable" do
      TestEngine.octo_config do
        add :funny_string, 'string'
      end
      expect(OctoConfig.mod_methods[:funny_string]).to eq('string')
      OctoConfig.finalize!
      expect(TestEngine.funny_string).to eq 'string'
    end
  end
end
