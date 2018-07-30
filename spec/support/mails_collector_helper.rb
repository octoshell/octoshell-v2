class MailsCollectorHelper
  ENGINES = {
              Announcements: [:announcement]
            }
  def self.user
    @user ||= FactoryGirl.create(:user)
  end

  def self.english_user
    @english_user ||= FactoryGirl.create(:user, language: 'en')
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
    ENGINES.each do |key, value|
      value.each do |meth|
        eval("#{key}Collector").send(meth, user)
        eval("#{key}Collector").send(meth, english_user)
      end
    end
  end
end
