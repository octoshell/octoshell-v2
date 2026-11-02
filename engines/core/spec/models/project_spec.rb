require 'main_spec_helper'
module Core
  RSpec.describe Project do
    it 'deactivates project' do
      @project = create_project
      @access = create(:core_access, project: @project)
      access_logger = []
      allow_any_instance_of(Access).to receive(:synchronize!) do
        access_logger << 'having_fun'
      end
      access_logger << 'before_before_having_fun'
      access_logger << 'before_having_fun'
      @project.activate!
      @project.save!
      access_logger << 'after_having_fun'
      expect(access_logger).to eq ['before_before_having_fun', 'before_having_fun', 'having_fun', 'after_having_fun']
    end

    it 'saves project' do
      project = create_project
      new_tech = create(:critical_technology)
      expect { project.update!(title: 'new_title') }.to change{ PaperTrail::Version.count }.by(1)

      expect {
        project.critical_technology_ids = [new_tech.id]
        project.save!
      }.to change { PaperTrail::Version.count }.by(1)

    end

  end
end
