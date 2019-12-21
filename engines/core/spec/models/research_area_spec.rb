module Core
  require 'main_spec_helper'
  describe ResearchArea do
    it "prevents removal of research area when project has only this area" do
      area = create(:research_area)
      project = create(:project, research_areas: [area])
      puts project.research_areas.reload.inspect.red
      area.destroy!
      # puts project.research_areas.reload.inspect.red
      project.save!
      # puts project.research_areas.reload.inspect.red
      # expect(Organization.find(id).city).to eq @city2
    end
  end
end
