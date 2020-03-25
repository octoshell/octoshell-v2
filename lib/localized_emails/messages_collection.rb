module LocalizedEmails
  class MessagesCollection
    attr_reader :mails
    def initialize
      @mails = []
    end
    def <<(mail)
      @mails << mail
    end

    %i[deliver deliver!].each do |sym|
      define_method(sym) do
        mails.each(&sym)
      end
    end
  end
end
