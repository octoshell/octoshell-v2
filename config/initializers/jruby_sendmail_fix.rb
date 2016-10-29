# got if from here: http://stackoverflow.com/questions/8746699/rails-app-wont-send-mail-via-sendmail-under-jruby

module Mail
  class Sendmail

    def initialize(values)
      self.settings = { :location       => '/usr/sbin/sendmail',
                        :arguments      => '-i -t' }.merge(values)
    end

    attr_accessor :settings

    def deliver!(mail)
      envelope_from = mail.return_path || mail.sender || mail.from_addrs.first
      return_path = "-f \"#{envelope_from.to_s.shellescape}\"" if envelope_from

      arguments = [settings[:arguments], return_path].compact.join(" ")

      Sendmail.call(settings[:location], arguments, mail.destinations.collect(&:shellescape).join(" "), mail)
    end

    def Sendmail.call(path, arguments, destinations, mail)
      IO.popen("#{path} #{arguments} #{destinations}", "r+") do |io|
        io.puts mail.encoded.to_lf
        io.close_write  # <------ changed this from flush to close_write
        sleep 1 # <-------- added this line
      end
    end
  end
end
