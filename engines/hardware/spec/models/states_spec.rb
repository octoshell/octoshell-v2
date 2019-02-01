module Hardware
  require "main_spec_helper"
  describe State do

    it "reads graph" do
      @state1 = create(:hardware_state)
      @state2 = create(:hardware_state)
      @state3 = create(:hardware_state)
      StatesLink.create!(from: @state1, to: @state2)

      expect(@state2.from_states).to eq([@state1])
      expect(@state1.to_states).to eq([@state2])
    end

  end
end
