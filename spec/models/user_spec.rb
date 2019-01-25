# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string(255)      not null
#  crypted_password                :string(255)
#  salt                            :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  activation_state                :string(255)
#  activation_token                :string(255)
#  activation_token_expires_at     :datetime
#  remember_me_token               :string(255)
#  remember_me_token_expires_at    :datetime
#  reset_password_token            :string(255)
#  reset_password_token_expires_at :datetime
#  reset_password_email_sent_at    :datetime
#  access_state                    :string(255)
#  deleted_at                      :datetime
#  last_login_at                   :datetime
#  last_logout_at                  :datetime
#  last_activity_at                :datetime
#  last_login_from_ip_address      :string(255)
#  language                        :string
#

require 'main_spec_helper'
describe User do
  before(:each) do
    @user = build(:user)
  end
  it 'saves user with default language option' do
    expect(@user.save).to eq(true)
    expect(@user.language).to eq('ru')
  end

  it "saves user" do
    @user.language = 'en'
    expect(@user.save).to eq(true)
    expect(@user.language).to eq('en')
  end

  it "doesn't saves user with incorrect language" do
    @user.language = 'non-existing-language'
    expect(@user.save).to eq(false)
  end
  describe '#cut_email' do
    it 'hides usual email' do
      @user = build(:user, email: 'unknown@gmail.com')
      expect(@user.cut_email).to eq 'unknown@g*l.com'
    end

    it 'hides email' do
      @user = build(:user, email: 'unknown@s.com')
      expect(@user.cut_email).to eq 'unknown@s.com'
    end

    it 'hides email too' do
      @user = build(:user, email: 'unknown@com')
      expect(@user.cut_email).to eq 'unknown@com'
    end
  end
end
