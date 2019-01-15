user = User.find_by_email 'admin@octoshell.ru'
ticket = Support::Ticket.where(reporter: user).last
body_raw =  ::Support::Mailer.new_ticket_reply(ticket.id, user.id).body.to_s #.gsub('-' * Support.dash_number,  '-' * Support.dash_number + 'I answer hello')
mail = Mail::Message.new do
  to 'support@octoshell.ru'
  subject 'Ticket title'
  body body_raw
  add_file filename: 'rus', content: File.read($0)
  #add_file filename: 'рус2', content: File.read($0)
end
mail.from = 'admin@octoshell.ru'

mail.delivery_method :exim, location: '/usr/sbin/exim'
mail.deliver
