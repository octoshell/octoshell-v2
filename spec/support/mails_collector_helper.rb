class MailsCollectorHelper

  OUTPUT_FILE = 'octoshell_mails.html'
  ENGINES = {
              Announcements: [:announcement]
            }
  def self.user
    @user ||= FactoryBot.create(:user)
  end

  def self.english_user
    @english_user ||= FactoryBot.create(:user, language: 'en')
  end

  class AnnouncementsCollector
    class << self
      def announcement(user)
        announcement = ::Announcement.create(title: 'aa', body: 'aaa')
        id = announcement.announcement_recipients.create(user: user).id
        ::Announcements::Mailer.announcement(id).deliver!
        announcement = ::Announcement.create(title: 'aa', body: 'aaa', is_special: true)
        id = announcement.announcement_recipients.create(user: user).id
        ::Announcements::Mailer.announcement(id).deliver!
      end
    end
  end

  class AuthenticationCollector
    class << self
      def activation
        user = ::User.first
        user.send_activation_needed_email!
        user.send_activation_success_email!
        user.send_reset_password_email!
      end
    end
  end

  def self.collect
    mails = []
    ENGINES.each do |key, value|
      value.each do |meth|
        mails << eval("#{key}Collector").send(meth, user)
        mails << eval("#{key}Collector").send(meth, english_user)
      end
    end
    puts mails.inspect
    # File.open(OUTPUT_FILE, 'w') do |f|
    #   f.write("write your stuff here")
    # end

  end
end
