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
      mails.each(&:deliver!)
    end
  end
end
