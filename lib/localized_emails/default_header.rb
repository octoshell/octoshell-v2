module LocalizedEmails
  module DefaultHeader
    def mail(args)
      headers['Auto-Submitted'] ||= 'auto-generated'
      super(args)
    end
  end
  ActionMailer::Base.prepend DefaultHeader
end
