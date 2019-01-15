require 'mail'
mail = Mail::Message.new do
  to 'support@octoshell.ru'
  subject 'Ticket title'
  body 'Ticket body'
  add_file filename: 'рус', content: File.read($0)
  add_file filename: 'рус2', content: File.read($0)
end
mail.from = 'admin@octoshell.ru'

mail.delivery_method :exim, location: '/usr/sbin/exim'
mail.deliver
