require 'receive_emails/config'
require 'receive_emails/email_processor'
require 'lmtp'
require 'zip'

module ReceiveEmails
  def self.lmtp_server
    ::LmtpServer.new(CONFIG[:socket_path], CONFIG[:socket_permissions]) do |msg|
      EmailProccessor.new(msg).process
    end
  end
  unless Rails.env.test?
    puts '== Starting =='
    lmtp_server.start
  end
end
