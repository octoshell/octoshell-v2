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
