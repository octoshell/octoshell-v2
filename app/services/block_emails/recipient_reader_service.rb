require 'net/imap'
require 'receive_emails/IMAP_connector'
module BlockEmails
  class RecipientReaderService < ReceiveEmails::IMAPConnector
    attr_reader :imap

    def call(box_name, date)
      imap.select(box_name)
      imap.search("SINCE #{date}").map do |message_id|
        email_content = imap.fetch(message_id, 'BODY[]')[0].attr['BODY[]']
        [
          email_header(email_content, 'Original-Recipient') ||
            email_header(email_content, 'Final-Recipient'),
          Mail::Message.new(email_content).text_part.decoded
        ]
      end
    end

    private

    def email_header(message, header)
      message.match(/^#{header}: rfc822;(.*)$/i) do |m|
        m[1].strip
      end
    end
  end
end
