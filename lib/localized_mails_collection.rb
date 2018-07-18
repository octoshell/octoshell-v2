class LocalizedMailsCollection
  def initialize
    @mails = []
  end
  def <<(mail)
    puts "<<"
    @mails << mail
  end
  def deliver!
    puts "DELIVER"
    mails.each!(&:deliver_now!)
  end
end
