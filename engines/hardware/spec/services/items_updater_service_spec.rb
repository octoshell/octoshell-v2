module Hardware
  require "main_spec_helper"
  describe Item do
    before(:each) do
      @kind = create(:hardware_kind)
      @kind2 = create(:hardware_kind)
      @state1 = create(:hardware_state, kind: @kind, name_en: 'initial')
      @state2 = create(:hardware_state, kind: @kind, name_en: 'finish')
      @state3 = create(:hardware_state, kind: @kind, name_en: 'no transitions')

      StatesLink.create!(from: @state1, to: @state2)
      # @item2 = create(:hardware_item)
      # @item3 = create(:hardware_item)

    end

    it "creates item" do
      ItemsUpdaterService.update!(['name_ru' => 'unique_name', 'kind_id' => @kind.id])
      expect(Item.last).to have_attributes(name_ru: 'unique_name', kind_id: @kind.id)
    end

    it "creates item with id = ''" do
      ItemsUpdaterService.update!(['id' => '', 'name_ru' => 'unique_name', 'kind_id' => @kind.id])
      expect(Item.last).to have_attributes(name_ru: 'unique_name', kind_id: @kind.id)
    end

    it "updates item" do
      @item = create(:hardware_item)
      ItemsUpdaterService.update!(['id' => @item.id.to_s, 'name_ru' => 'unique_name'])
      expect(Item.find(@item.id.to_s)).to have_attributes(name_ru: 'unique_name')
    end



    it "creates item with state" do
      ItemsUpdaterService.update!(['name_ru' => 'unique_name',
                                   'kind_id' => @kind.id,
                                   'state' => { 'reason_en' => 'I want',
                                                'state_id' => @state3.id.to_s }])
      expect(Item.last).to have_attributes(name_ru: 'unique_name', kind_id: @kind.id)
      expect(Item.last.last_items_state).to have_attributes(reason_en: 'I want',
                                                            state_id: @state3.id )
    end

    it "updates item with state" do
      @item = create(:hardware_item)
      ItemsUpdaterService.update!(['id' => @item.id.to_s,
                                   'name_ru' => 'unique_name',
                                   'kind_id' => @kind.id,
                                   'state' => { 'reason_en' => 'I want',
                                                'state_id' => @state3.id.to_s }])
      expect(Item.last).to have_attributes(name_ru: 'unique_name', kind_id: @kind.id)
      expect(Item.find(@item.id).last_items_state).to have_attributes(reason_en: 'I want',
                                                                      state_id: @state3.id )
    end

    it "updates item without change of state" do
      @item = create(:hardware_item, kind: @kind)
      @item.items_states.create!(state_id: @state1.id)
      ItemsUpdaterService.update!(['id' => @item.id.to_s,
                                   'name_ru' => 'unique_name',
                                   'kind_id' => @kind.id,
                                   'state' => { 'reason_en' => 'I want' }])
      expect(Item.last).to have_attributes(name_ru: 'unique_name', kind_id: @kind.id)
      expect(Item.find(@item.id).last_items_state).to have_attributes(reason_en: 'I want',
                                                                      state_id: @state1.id )
    end

    it "doesn't create state because no state id specified" do
      @item = create(:hardware_item)
      expect{
        ItemsUpdaterService.update!(['id' => @item.id.to_s,
                                     'name_ru' => 'unique_name',
                                     'kind_id' => @kind.id,
                                     'state' => { 'reason_en' => 'I want' }])
      }.to raise_error

    end

    it "#to_a" do
      @item = create(:hardware_item, kind: @kind)
      @item2 = create(:hardware_item)
      @item.items_states.create!(state_id: @state1.id)
      @hash = ItemsUpdaterService.to_a

      ItemsUpdaterService.update!(['id' => @hash.first['id'].to_s,
                                  'state' => { 'reason_en' => 'I want',
                                  'state_id' => @state2.id.to_s }])
      puts @hash
      expect(Item.find(@hash.first['id']).items_states.last).to have_attributes(reason_en: 'I want', state_id: @state2.id)

    end


  end
end
