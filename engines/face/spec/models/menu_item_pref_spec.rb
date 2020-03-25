require "main_spec_helper"
module Face
  describe MenuItemPref do
    before(:each) do
      @user = create(:user)
      @conditions = { user: @user, menu: 'menu', admin: false }
    end

    describe '.edit_all' do
      it '1' do
        @pref1 = MenuItemPref.create!(@conditions.merge(position: 0, key: 'first'))
        expect(MenuItemPref.all.to_a).to match_array(@pref1)
        MenuItemPref.edit_all(['second'], @conditions)
        expect(MenuItemPref.all.order(:position).to_a.map(&:key)).to eq ['second', @pref1.key]
        @pref1.reload
        expect(@pref1.position).to eq 1

      end

      it '2' do
        @pref1 = MenuItemPref.create!(@conditions.merge(position: 0, key: 'first'))
        expect(MenuItemPref.all.to_a).to match_array(@pref1)
        MenuItemPref.edit_all(['second', 'first'], @conditions)
        expect(MenuItemPref.all.order(:position).to_a.map(&:key)).to eq ['second', @pref1.key]
      end

      it '3' do
        @pref1 = MenuItemPref.create!(@conditions.merge(position: 0, key: 'first'))
        expect(MenuItemPref.all.to_a).to match_array(@pref1)
        MenuItemPref.edit_all(['first', 'second'], @conditions)
        expect(MenuItemPref.all.order(:position).to_a.map(&:key)).to eq ['first', 'second']
      end


    end

  end
end
