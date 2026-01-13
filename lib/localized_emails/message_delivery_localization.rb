module LocalizedEmails
  module MessageDeliveryLocalization
    extend ActiveSupport::Concern
    DEFAULT_LOCALE = 'en'.freeze

    def form_mailer
      @mailer_class.new.tap do |mailer|
        mailer.process @action, *@args
      end
    end

    def old_message
      form_mailer.message
    end

    def language
      processed_mailer.try(:language)
    end

    def deliver!
      deliver_now!
    end

    def deliver
      deliver_now
    end

    def non_blocking_delivery?
      processed_mailer.try(:non_blocking_delivery?)
    end

    def message
      messages = MessagesCollection.new
      addresses = Array(old_message.to)
      users = User.where(email: addresses).to_a
      unless non_blocking_delivery?
        users.select(&:block_emails).each do |u|
          addresses.delete(u.email)
        end
      end
      BatchSidekiq.raise_error_if_limit_reached(addresses.count) unless Rails.env.test?
      grouped_addresses = addresses.group_by do |to|
        language || users.detect { |u| u.email == to }&.language || DEFAULT_LOCALE
      end
      grouped_addresses.each do |key, value|
        I18n.with_locale(key) do
          message = old_message
          message.to = value
          messages << message
        end
      end
      messages
    end
  end
  ActionMailer::MessageDelivery.prepend MessageDeliveryLocalization
end
