require 'net/imap'
module ReceiveEmails
  class IMAPConnector
    def initialize(config = Rails.application.secrets.imap)
      raise 'No config supplied for IMAP connection' unless config

      @config = config
      @imap = Net::IMAP.new(@config[:host], @config.slice(:port, :ssl))
      @imap.login(@config[:login], @config[:password])
    end

    def list
      @imap.list('', '*')
    end

    def call
      @imap.select('INBOX')
      ids = @imap.uid_search(['UNSEEN'])
      ids.each do |uid|
        raw_message = @imap.uid_fetch(uid, 'RFC822').first.attr['RFC822']
        EmailProccessor.new(raw_message).process
      end
    end
  end
end
