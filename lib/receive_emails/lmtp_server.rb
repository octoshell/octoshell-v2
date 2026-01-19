require 'receive_emails/email_processor'
require 'lmtp'
require 'zip'

module ReceiveEmails
  CONFIG = {
    socket_path: 'mail.sock',
    socket_permissions: 066
  }
  def self.lmtp_server
    path = CONFIG[:socket_path]
    File.delete(path) if File.exist? path
    ::LmtpServer.new(CONFIG[:socket_path], CONFIG[:socket_permissions]) do |msg|
      EmailProccessor.new(msg).process
    end
  end

  def self.start_server
    puts '== Starting =='
    lmtp_server.start
  end
end
