require 'main_spec_helper'
require 'receive_emails/lmtp_server'
module ReceiveEmails
  describe "ReceiveEmails", type: :mailer do
    before(:all) do
      @server = ReceiveEmails.lmtp_server
      Thread.new { @server.start }
      @user = create_admin
      @mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body 'Ticket body'
        add_file filename: 'somefile.rb', content: File.read($0)
      end
      @mail.from = @user.email
    end
    after(:all) do
      @server.stop
    end

    it 'creates new ticket without text body' do
      @mail_without_body = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        add_file filename: 'somefile.rb', content: File.read($PROGRAM_NAME)
      end
      @mail_without_body.from = @user.email
      expect { to_exim @mail_without_body }.to change{ Support::Ticket.count }.by 1
      expect(Support::Ticket.last).to have_attributes(reporter: @user,
                                                      subject: 'Ticket title')
      @ticket = Support::Ticket.last
      expect(@ticket.attachment.url.split('/').last).to eq 'somefile.rb'
    end

    it 'creates new ticket with one attachment' do
      expect { to_exim @mail }.to change { Support::Ticket.count }.by 1
      expect(Support::Ticket.last).to have_attributes(reporter: @user,
                                                      message: 'Ticket body',
                                                      subject: 'Ticket title')
      @ticket = Support::Ticket.last
      expect(@ticket.attachment.url.split('/').last).to eq 'somefile.rb'
    end

    it 'creates new ticket with 2 attachments in Russian' do
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body 'Ticket body'
        add_file filename: 'eng', content: File.read($0)
        add_file filename: 'eng2', content: File.read($0)
      end
      mail.from = @user.email

      expect { to_exim mail }.to change { Support::Ticket.count }.by 1
      expect(Support::Ticket.last).to have_attributes(reporter: @user,
                                                      message: 'Ticket body',
                                                      subject: 'Ticket title')
      ticket = Support::Ticket.last
      expect(ticket.attachment.url.split('/').last).to eq 'attachments.zip'
    end


    it 'creates new ticket with one attachment in Russian' do
      @mail_ru = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body 'Ticket body'
        add_file filename: 'по-русски', content: File.read($0)
      end
      @mail_ru.from = @user.email

      expect { to_exim @mail_ru }.to change { Support::Ticket.count }.by 1
      expect(Support::Ticket.last).to have_attributes(reporter: @user,
                                                      message: 'Ticket body',
                                                      subject: 'Ticket title')
      @ticket = Support::Ticket.last
      expect(@ticket.attachment.url.split('/').last).to eq 'po-russki'
    end


    it 'creates new ticket without attachment' do
      @mail_without_attachment = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body 'Ticket body'
      end
      @mail_without_attachment.from = @user.email
      expect { to_exim @mail_without_attachment }.to change { Support::Ticket.count }.by 1
      expect(Support::Ticket.last).to have_attributes(reporter: @user,
                                                      message: 'Ticket body',
                                                      subject: 'Ticket title')
    end

    it "creates new ticket without attachment with Auto-Submitted == 'no'" do
      @mail_without_attachment = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body 'Ticket body'
      end
      @mail_without_attachment.header['Auto-Submitted'] = 'no'
      @mail_without_attachment.from = @user.email
      expect { to_exim @mail_without_attachment }.to change { Support::Ticket.count }.by 1
      expect(Support::Ticket.last).to have_attributes(reporter: @user,
                                                      message: 'Ticket body',
                                                      subject: 'Ticket title')
    end



    it 'does not create new ticket with Auto-Submitted header' do
      @mail.headers['Auto-Submitted'] = 'auto-replied'
      @mail.from = 'andrey@andrey-vostro-3558'
      @mail.to = 'andrey@andrey-vostro-3558'
      @mail.subject = 'I am auto-submitted'
      expect { to_exim @mail }.to change{ Support::Ticket.count }.by 0
    end

    it 'does not create new ticket' do
      @mail.from = 'notexist@mail.ru'
      expect { to_exim @mail }.to change{ Support::Ticket.count }.by 0
    end

    it 'creates new reply to ticket via email without attachment' do
      ticket = create(:ticket)
      support = create_support
      ticket.replies.create!(message: 'hello', author: support)
      new_body = ActionMailer::Base.deliveries.last.body.to_s
                                   .gsub('-' * Support.dash_number,  '-' * Support.dash_number + 'I answer hello')
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body new_body
      end
      mail.from = support.email
      expect { to_exim mail }.to change{ Support::Reply.count }.by 1
      expect(Support::Reply.last).to have_attributes(author: support,
                                                     message: 'I answer hello',
                                                     ticket: ticket)
    end

    it 'does not creates new reply for foreign ticket ' do
      ticket = create(:ticket)
      user = create(:user)
      support = create_support
      ticket.replies.create!(message: 'hello', author: support)
      new_body = ActionMailer::Base.deliveries.last.body.to_s.gsub('-' * Support.dash_number,  '-' * Support.dash_number + 'I answer hello')
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body new_body
      end
      mail.from = user.email
      expect { to_exim mail }.to change{ Support::Reply.count }.by 0
    end


    it 'does not create new reply to ticket via email without attachment and with empty reply' do
      ticket = create(:ticket)
      support = create_support(language: 'en')
      ticket.replies.create!(message: 'hello', author: support)
      new_body = ActionMailer::Base.deliveries.last.body.to_s
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body new_body
      end
      mail.from = support.email
      expect { to_exim mail }.to change{ Support::Reply.count }.by 0
      puts ActionMailer::Base.deliveries.last.inspect.yellow
    end

    it 'creates new reply to ticket via email with attachment' do
      ticket = create(:ticket)
      support = create_support
      ticket.replies.create!(message: 'hello', author: support)
      new_body = ActionMailer::Base.deliveries.last.body.to_s.gsub('-' * Support.dash_number,  '-' * Support.dash_number + 'I answer hello')
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body new_body
        add_file filename: 'somefile.rb', content: File.read($0)
      end
      mail.from = support.email
      ticket.close
      expect { to_exim mail }.to change{ Support::Reply.count }.by 1
      expect(Support::Reply.last).to have_attributes(author: support,
                                                     message: 'I answer hello',
                                                     ticket: ticket)
      expect(Support::Ticket.last.state).to eq 'answered_by_support'
      expect(Support::Reply.last.attachment.url.split('/').last).to eq 'somefile.rb'
    end

    it 'creates new reply to ticket via email with attachment' do
      ticket = create(:ticket)
      support = create_support
      ticket.replies.create!(message: 'hello', author: support)
      new_body = ActionMailer::Base.deliveries.last.body.to_s.gsub('-' * Support.dash_number,  '-' * Support.dash_number + 'I answer hello')
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body new_body
        add_file filename: 'somefile.rb', content: File.read($0)
      end
      mail.from = support.email
      expect { to_exim mail }.to change{ Support::Reply.count }.by 1
      expect(Support::Reply.last).to have_attributes(author: support,
                                                     message: 'I answer hello',
                                                     ticket: ticket)
      expect(Support::Reply.last.attachment.url.split('/').last).to eq 'somefile.rb'
    end

    it 'creates new reply to ticket via email with attachment and removes html tags' do
      answer_string = '<div class="mail-Message-Body-Content"><blockquote type="cite" data-level="1" class="b-quote b-quote_lt b-quote_odd b-quote_a b-quote_lf b-quote_ll b-quote__b_sep b-quote__cb_sep b-quote_expanded" data-processed="bc sa fa aps lf ll qw qws"><div class="b-quote_content js-quote_content"><div class="b-quote__author js-quote-ignore js-quote-expand"><span class="b-quote__author_ava"><span data-id="recipient-12" id="recipient-12" class="mail-User-Avatar mail-User-Avatar_size_36 mail-User-Avatar_short_mono" style="background-color: #1A1A1A;">O</span></span><span class="b-quote__author_name">Octoshell Notifier</span><span class="b-quote__author_email">&lt;<a href="mailto:info@users.parallel.ru" class="ns-action b-quote__author_email_link" data-click-action="common.go" data-params="new_window&amp;url=#compose/mailto=info%40users.parallel.ru">info@users.parallel.ru</a>&gt;</span><span class="b-quote__author_date">9 сен. в 12:22</span><span class="b-quote__control_expand js-quote-expand-toggle js-quote-control-expand"><span class="b-quote__control_expand_ico"></span></span></div><div class="b-quote__firstline js-quote-ignore js-quote-expand"><div class="b-quote__firstline_content">Здравствуйте, Паокин Андрей Викторович!</div></div><div class="b-quote__ctrls js-quote-ignore"><span class="b-quote__button js-quote-expand" data-ids="170010885933249016"><span class="b-quote__button-i">Показать цитату целиком</span></span><span class="b-quote__button js-quote-expand-all" data-ids="170010885933249016"><span class="b-quote__button-i">Показать всю переписку</span></span><span class="b-quote__button b-quote__button_maximize_begin js-quote-maximize"><span class="b-quote__button-i">Показать начало цитаты</span></span><span class="b-quote__button b-quote__button_maximize_part js-quote-maximize"><span class="b-quote__button-i">Показать часть цитаты</span></span><span class="b-quote__button b-quote__button_maximize_end js-quote-maximize"><span class="b-quote__button-i">Показать конец цитаты</span></span><span class="b-quote__loading"><img class="b-mail-icon b-mail-icon_ajax-loader" src="//yastatic.net/s3/liza/_/2966ad46f182d8d22e58f5f1c200484b-b-mail-icon_ajax-loader.gif"></span></div><div class="b-quote__i js-quote-content" data-processed="cq"><p style="padding-bottom:16px">Здравствуйте, Паокин Андрей Викторович!</p><blockquote type="cite" data-level="2" class="b-quote b-quote_even b-quote_lf b-quote__t_sep b-quote__b_sep b-quote_expanded" data-processed="lf bc sa qw qws"><div class="b-quote_content js-quote_content"><div class="b-quote__firstline js-quote-ignore js-quote-expand"><div class="b-quote__firstline_content">Паокин Андрей Викторович Принято! Жуматий Сергей Анатольевич Раз-два, раз-два-три, проверка... (С)</div></div><div class="b-quote__ctrls js-quote-ignore"><span class="b-quote__button js-quote-expand" data-ids=""><span class="b-quote__button-i">Показать цитату целиком</span></span><span class="b-quote__button js-quote-expand-all" data-ids=""><span class="b-quote__button-i">Показать всю переписку</span></span><span class="b-quote__button b-quote__button_maximize_begin js-quote-maximize"><span class="b-quote__button-i">Показать начало цитаты</span></span><span class="b-quote__button b-quote__button_maximize_part js-quote-maximize"><span class="b-quote__button-i">Показать часть цитаты</span></span><span class="b-quote__button b-quote__button_maximize_end js-quote-maximize"><span class="b-quote__button-i">Показать конец цитаты</span></span><span class="b-quote__loading"><img class="b-mail-icon b-mail-icon_ajax-loader" src="//yastatic.net/s3/liza/_/2966ad46f182d8d22e58f5f1c200484b-b-mail-icon_ajax-loader.gif"></span></div><div class="b-quote__i js-quote-content"><p><strong>Паокин Андрей Викторович</strong></p><p>Принято!</p><p><strong>Жуматий Сергей Анатольевич</strong></p><p>Раз-два, раз-два-три, проверка... (С)</p></div></div><div class="mail-Quote-Toggler js-mail-Quote-Toggler is-hidden"><svg xmlns="http://www.w3.org/2000/svg" class="svgicon svgicon-mail--Message-Quotation"><use xlink:href="#svgicon-mail--Message-Quotation"></use><rect height="100%" width="100%" style="fill: transparent;"></rect></svg>Показать цитирование</div></blockquote><p><a href="http://users.parallel.ru/support/admin/tickets/6367" data-vdir-href="https://mail.yandex.ru/re.jsx?uid=56494135&amp;c=LIZA&amp;cv=17.9.156&amp;mid=170010885933249016&amp;h=a,q8L_HJKDF9HAZwHI2YgfGw&amp;l=aHR0cDovL3VzZXJzLnBhcmFsbGVsLnJ1L3N1cHBvcnQvYWRtaW4vdGlja2V0cy82MzY3" data-orig-href="http://users.parallel.ru/support/admin/tickets/6367" class="daria-goto-anchor" target="_blank" rel="noopener noreferrer">Перейти к заявке</a></p><p style="padding-top:24px">С уважением, Octoshell.</p><hr><p style="color:#666">Лаборатория Параллельных информационных технологий НИВЦ МГУ.</p><p>ticket_id:6367 Не удаляйте эту строку! Вы можете добавить ответ к этой заявке, записав Ваш ответ после следующей пунктирной линии.</p>------------------------------------------------------------------------------------------------------------------------------------------------------</div></div><div class="mail-Quote-Toggler js-mail-Quote-Toggler is-hidden"><svg xmlns="http://www.w3.org/2000/svg" class="svgicon svgicon-mail--Message-Quotation"><use xlink:href="#svgicon-mail--Message-Quotation"></use><rect height="100%" width="100%" style="fill: transparent;"></rect></svg>Показать цитирование</div></blockquote><div>Мой ответ из email</div></div>'
      ticket = create(:ticket)
      support = create_support
      ticket.replies.create!(message: 'hello', author: support)
      # new_body = ActionMailer::Base.deliveries.last.body.to_s.gsub('-' * Support.dash_number,  '-' * Support.dash_number + 'I answer hello')
      answer_string.gsub!(/ticket_id:\d+/, "ticket_id:#{ticket.id}")
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body answer_string
        add_file filename: 'somefile.rb', content: File.read($0)
      end
      mail.from = support.email
      expect { to_exim mail }.to change{ Support::Reply.count }.by 1
      # puts Support::Reply.last.message.inspect
      expect(Support::Reply.last).to have_attributes(author: support,
                                                     message: 'Показать цитированиеМой ответ из email',
                                                     ticket: ticket)
      expect(Support::Reply.last.attachment.url.split('/').last).to eq 'somefile.rb'

    end

    it 'creates new reply to ticket via email with 2 attachments' do
      ticket = create(:ticket)
      support = create_support
      ticket.replies.create!(message: 'hello', author: support)
      new_body = ActionMailer::Base.deliveries.last.body.to_s.gsub('-' * Support.dash_number,  '-' * Support.dash_number + 'I answer hello')
      mail = Mail::Message.new do
        to 'support@octoshell.ru'
        subject 'Ticket title'
        body new_body
        add_file filename: 'somefile.rb', content: File.read($0)
        add_file filename: 'somefile2W.rb', content: File.read($0)
      end
      mail.from = support.email
      expect { to_exim mail }.to change{ Support::Reply.count }.by 1
      expect(Support::Reply.last).to have_attributes(author: support,
                                                     message: 'I answer hello',
                                                     ticket: ticket)
      expect(Support::Reply.last.attachment.url.split('/').last).to eq 'attachments.zip'
    end
  end
end
