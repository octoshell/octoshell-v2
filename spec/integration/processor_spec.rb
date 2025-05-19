require 'main_spec_helper'
require 'receive_emails/email_processor'

module ReceiveEmails
  describe EmailProccessor do
    before(:all) do
    #   @server = ReceiveEmails.lmtp_server
    #   Thread.new { @server.start }
    #   @user = create_admin
    #   @mail = Mail::Message.new do
    #     to 'support@octoshell.ru'
    #     subject 'Ticket title'
    #     body 'Ticket body'
    #     add_file filename: 'somefile.rb', content: File.read($0)
    #   end
    #   @mail.from = @user.email
    end
    after(:all) do
      # @server.stop
    end

    it 'creates reply when ticket_id is in message and user is allowed to create ticket' do
      ticket = create(:ticket)
      email = create(:admin).email
      expect{EmailProccessor.new(
        Mail::Message.new do
           from email
           to 'support@octoshell.ru'
           subject 'Ticket title'
           body 'my answer' + ticket.message + "ticket_id:#{ticket.id}"
         end.to_s
      ).process
    }.to change{Support::Reply.where(ticket_id: ticket).count}.by(1)
    end

    # describe 'date methods' do
    #   it "stores and load date" do
    #     path = '/tmp/date.txt'
    #     date = DateTime.now
    #     Processor.save_date(date, path)
    #     loaded = Processor.load_date(path)
    #     expect(date.to_s).to eq loaded.to_s
    #   end
    # end


  end
end
