module LocalizedEmails
  class MessagesCollection
    attr_reader :mails
    def initialize
      @mails = []
    end
    def <<(mail)
      @mails << mail
    end

    def deliver!
      begin
        mails.each(&:deliver!)
      rescue => e
        logger.info "Email Deliver error: #{e.message}"
      end
    end
  end
end
