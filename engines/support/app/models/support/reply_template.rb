# == Schema Information
#
# Table name: support_reply_templates
#
#  id         :integer          not null, primary key
#  subject_ru :string(255)
#  message_ru :text
#  subject_en :string
#  message_en :text
#

# Шаблон ответа на тикет
module Support
  class ReplyTemplate < ActiveRecord::Base

    has_paper_trail

    translates :subject, :message
    validates_translated :subject, :message, presence: true
    def to_s
      subject
    end
  end
end
