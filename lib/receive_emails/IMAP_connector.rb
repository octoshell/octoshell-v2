require 'net/imap'
module ReceiveEmails
  class IMAPConnector
    def initialize(config = Rails.configuration.secrets[:email])
      raise 'No config supplied for IMAP connection' unless config

      @config = config
      @imap = Net::IMAP.new(@config[:host], @config.slice(:imap_port, :ssl))
      @imap.login(@config[:login], @config[:password])
    end

    def list
      @imap.list('', '*')
    end

    def call
      @imap.select('INBOX')
      @imap.uid_search(['UNFLAGGED']).each do |uid|
        raw_message = @imap.uid_fetch(uid, 'RFC822').first.attr['RFC822']
        ActiveRecord::Base.transaction do
          EmailProccessor.new(raw_message).process
          @imap.uid_store(uid, '+FLAGS', [:Flagged])
        end
      end
    end
  end
end
