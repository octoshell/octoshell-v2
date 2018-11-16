module Hardware
  require "main_spec_helper"
  describe ItemsState do
    before(:each) do
      @kind = create(:hardware_kind)
      @item = create(:hardware_item, kind: @kind)
      @state1 = create(:hardware_state, kind: @kind, name_en: 'initial')
      @state2 = create(:hardware_state, kind: @kind, name_en: 'finish')
      @state3 = create(:hardware_state, kind: @kind, name_en: 'no transitions')
      @invalid_state = create(:hardware_state)

      StatesLink.create!(from: @state1, to: @state2)
      @item.items_states.create!(state: @state1)
    end

    it "changes state" do
      @item.items_states.create!(state: @state2)
      expect(@item.last_items_state.state.name_en).to eq('finish')
    end

    it "changes state with no states assigned" do
      @item2 = create(:hardware_item, kind: @kind)
      @item2.items_states.create!(state: @state3)
      expect(@item2.last_items_state.state.name_en).to eq('no transitions')
    end



    it "does not change state" do
      @item.items_states.create(state: @state3)
      expect(@item.last_items_state.state.name_en).to eq('initial')
    end

    it "no transition to state with different kind" do
      @item.items_states.create(state: @invalid_state)
      expect(@item.last_items_state.state.name_en).to eq('initial')
    end


  end
end
