module MultipleLocalesForEmails
  extend ActiveSupport::Concern
  DEFAULT_LOCALE = 'en'.freeze
  def mail(headers = {}, &block)
    puts "SSS"
    puts headers.inspect
    mails = LocalizedMailsCollection.new
    addresses = Array(headers[:to])
    addresses.each do |to|
      puts to
      locale = User.find_by_email(email: to)&.language || DEFAULT_LOCALE
      I18n.with_locale(locale) do
        mails << super(headers.merge(to: to), &block)
      end
    end
    mails
  end
end
ActionMailer::Base.prepend MultipleLocalesForEmails
