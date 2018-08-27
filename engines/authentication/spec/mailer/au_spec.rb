require ""
module Authentication
  describe Mailer, :type => :mailer do
    before(:each) do
      @user = build(:user)
      @user.language = 'ru'
      @user.save!
      @mail = Mailer.activation_success(@user.email)
    end
    it "renders the headers" do
      puts @mail.inspect
    end
  end
end
