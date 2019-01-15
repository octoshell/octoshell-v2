require 'mail'
mail = Mail::Message.new do
  to 'support@octoshell.ru'
  subject 'Ticket title'
  body 'Ticket body'
  add_file filename: 'somefile.rb', content: File.read($0)
end
mail.from = 'admin@octoshell.ru'

mail.delivery_method :exim, location: '/usr/sbin/exim'
mail.deliver
