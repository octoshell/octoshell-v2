require 'main_spec_helper'
module Core
  RSpec.describe Notice do

    describe "::notices_for_user" do
      let(:user) { create(:user) }
      it 'shows only user notifications' do
        user_notices = [create(:notice),
                        create(:notice, category: '1', sourceable: user)]
        create(:notice, category: 1, sourceable_id: user.id + 1)
        expect(Notice.notices_for_user(user).to_a).to match_array user_notices
      end

      it 'does not show old or future notifications' do
        create(:notice, show_from: DateTime.current + 1.hours)
        create(:notice, show_till: DateTime.current - 1.seconds)
        expect(Notice.notices_for_user(user).any?).to eq false
      end

      it 'shows notifications with show options' do
        notice = create(:notice)
        notice.notice_show_options.create!(user: user)
        expect(Notice.notices_for_user(user).to_a).to contain_exactly(notice)
      end

      it 'does not show hidden notifications' do
        notice = create(:notice)
        notice.notice_show_options.create!(user: user)
        notice2 = create(:notice)
        notice2.notice_show_options.create!(user_id: create(:user).id, hidden: true)
        create(:notice).notice_show_options.create!(user: user, hidden: true)
        expect(Notice.notices_for_user(user).to_a).to contain_exactly(notice, notice2)
      end
    end
  end
end
