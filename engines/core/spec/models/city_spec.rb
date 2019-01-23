module Core
  require 'main_spec_helper'
  describe City do
    describe "city" do
      it "1" do
        @org1 = create(:organization)
        @org2 = create(:organization)
        @city1 = @org1.city
        @city2 = @org2.city
        @city1.merge_with! @city2
        id = @org1.id
        expect(Organization.find(id).city).to eq @city2
      end
    end
  end
end
