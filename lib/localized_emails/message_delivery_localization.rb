module LocalizedEmails
  module MessageDeliveryLocalization
    extend ActiveSupport::Concern
    DEFAULT_LOCALE = 'ru'.freeze

    def new_message
      @mailer.send(:new, @mail_method, *@args).message
    end

    def message
      messages = MessagesCollection.new
      addresses = Array(new_message.to)
      grouped_addresses = addresses.group_by do |to|
        User.find_by_email(to)&.language || DEFAULT_LOCALE
      end
      grouped_addresses.each do |key, value|
        I18n.with_locale(key) do
          message = new_message
          message.to = value
          messages << message
        end
      end
      messages
    end
  end
  ActionMailer::MessageDelivery.prepend MessageDeliveryLocalization
end
