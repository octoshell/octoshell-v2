module BlockEmails
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attr_accessor :name, :date_gte

    validates :name, :date_gte, presence: true

    def try_to_submit
      return false unless valid?

      RecipientReaderService.new.call(name, date_gte_for_service)
    rescue Date::Error
      errors.add(:date_gte, :invalid)
      false
    rescue Net::IMAP::NoResponseError => e
      errors.add(:name, e.message)
      false
    end

    def date_gte_for_service
      Date.parse(date_gte).strftime('%d-%b-%Y')
    end


  end
end
