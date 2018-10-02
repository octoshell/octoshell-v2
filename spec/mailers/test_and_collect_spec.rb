require "initial_create_helper"
describe "Mailers", :type => :mailer do
  it 'collects all emails in Octoshell' do
		MailsCollectorHelper.collect
  end
end
