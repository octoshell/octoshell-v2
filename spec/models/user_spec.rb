require 'initial_create_helper'
describe User do
  before(:each) do
    @user = build(:user)
  end
  it 'saves user with default language option' do
    expect(@user.save).to eq(true)
    expect(@user.language).to eq('ru')
  end

  it "saves user" do
    # @user.build_lang_pref(language: 'en')
    @user.language = 'en'
    expect(@user.save).to eq(true)
    expect(@user.language).to eq('en')
  end

  it "doesn't saves user with incorrect language" do
    @user.language = 'non-existing-language'
    expect(@user.save).to eq(false)
  end


end
