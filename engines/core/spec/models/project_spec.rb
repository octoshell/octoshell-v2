require 'main_spec_helper'
module Core
  RSpec.describe Project do
    it 'deactivates project' do
      @project = create_project
      @access = create(:core_access, project: @project)
      AccessLogger = []
      class Access
        def synchronize!
          AccessLogger << "having_fun"
        end
      end
      # puts @project.inspect
      AccessLogger << 'before_before_having_fun'
      AccessLogger << 'before_having_fun'
      @project.activate!
      # puts @project.inspect
      # puts Core::Project.find(@project.id).inspect
      @project.save!
      # puts @project.inspect
      AccessLogger << 'after_having_fun'
      expect(AccessLogger).to eq ['before_before_having_fun', 'before_having_fun', 'having_fun', 'after_having_fun' ]
      # @project.block!
      # @project.save!
      # puts @project.inspect
    end
  end
end
