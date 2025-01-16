require 'zip'
module ReceiveEmails
  class EmailProccessor

    attr_reader :message, :user
    delegate :to, :from, to: :message

    def ticket_creation_allowed?
      true
    end

    def initialize(email_string)
      @message = Mail::Message.new email_string
      @user = User.find_by_email from
    end

    def continue_processing?
      user && (!message.header['Auto-Submitted'] ||
               message.header['Auto-Submitted'].to_s == 'no') &&
        !message.header['X-Autorespond']
    end

    def topic
      Support::Topic.find_or_create_by!(name_ru: 'Через email',
                                        name_en: 'Via email',
                                        visible_on_create: false)
    end

    def file_content?(item)
      # %w[application audio image message video].include? item.content_type.split('/').first
      item.filename
    end

    def text_content?(item)
      item.content_type.start_with?('text/')
    end

    def text_part
      text_content?(@message) && @message ||
        message.parts.detect { |part| text_content? part }
    end

    def file_parts
      # file_content?(@message) && @message ||
      message.parts.select { |part| file_content? part }
    end


    def new_ticket_message
      (text_part&.body || @message.content_type.to_s.inspect)
        .to_s.gsub(/\n$/, '')

    end

    def add_attachment(model_instance, content, name)
      file = Tempfile.new(name)
      begin
        file.puts content.force_encoding("UTF-8")
        model_instance.attachment = ActionDispatch::Http::UploadedFile.new(filename: Translit.convert(file_parts.first.filename, :english), tempfile: file)
        model_instance.save!
      ensure
        file.close
        file.unlink
      end

    end

    def zip_and_add_attachments(model_instance)
      file = Tempfile.new('attachments.zip')
      begin
        content = Zip::OutputStream.write_buffer do |stream|
          file_parts.each do |file_part|
            stream.put_next_entry Translit.convert(file_part.filename, :english)
            stream.write file_part.body.to_s.force_encoding("UTF-8")
          end
        end
        file.puts content.string.force_encoding("UTF-8")
        model_instance.attachment = ActionDispatch::Http::UploadedFile.new(filename: 'attachments.zip', tempfile: file)
        model_instance.save!
      ensure
        file.close
        file.unlink
      end
    end

    def create_ticket
      return unless ticket_creation_allowed?
      ticket = Support::Ticket.new(subject: message.subject,
                                   message: new_ticket_message,
                                   topic: topic,
                                   reporter: user)
      add_attachments_and_save ticket
    end

    def create_reply(ticket_id)
      if User.superadmins.exclude?(user) && User.support.exclude?(user) &&
         Support::Ticket.find(ticket_id).reporter != user
        raise 'foreign ticket'
      end
      message_body = new_ticket_message.rpartition(/-{#{Support.dash_number}}/).last
      reply = Support::Reply.new(message:  message_body,
                                 ticket_id: ticket_id,
                                 author: user)
      reply.ticket.reopen if reply.ticket.may_reopen?
      add_attachments_and_save reply
    end

    def add_attachments_and_save(record)
      if file_parts.any?
        if file_parts.count == 1
          add_attachment(record, file_parts.first.body.to_s, file_parts.first.filename)
        else
          zip_and_add_attachments record
        end
      else
        record.save!
      end
    end

    def process
      return unless continue_processing?

      begin
        ticket_string = text_part&.body.to_s[/ticket_id:\d+.*-{#{Support.dash_number}}/]
        if ticket_string
          I18n.with_locale(user.language.to_sym) do
            ActiveRecord::Base.transaction do
              create_reply ticket_string[/ticket_id:\d+/][/\d+/]
            end
          end
        else
          create_ticket
        end
      rescue ActiveRecord::RecordInvalid => e
        Support::MailerWorker.perform_async(:reply_error, [e.record.ticket_id,
                                                           user.id, e])
      end
    end
  end
end
