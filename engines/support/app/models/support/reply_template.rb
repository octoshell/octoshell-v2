# Шаблон ответа на тикет
module Support
  class ReplyTemplate < ActiveRecord::Base
    translates :subject, :message
    validates_translated :subject, :message, presence: true
    def to_s
      subject
    end
  end
end
