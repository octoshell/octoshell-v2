# Шаблон ответа на тикет
module Support
  class ReplyTemplate < ActiveRecord::Base
    validates :subject, presence: true

    translates :subject, :message

    def to_s
      subject
    end
  end
end
