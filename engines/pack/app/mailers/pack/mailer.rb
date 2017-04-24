module Pack
  class Mailer < ActionMailer::Base
    

    def access_changed(id,longer='no')
      @access=Access.find id

      receiver=if @access.who_type=='User'
        @access.who.email
      elsif @access.who_type=='Core::Project'
        @access.who.owner.email
      end
      @status_info=if longer!='no'
        t("mailer_messages.#{longer}")
      else
        t("mailer_messages.#{@access.status}")
      end
      mail to: receiver, subject: t("mailer_messages.subject",version_name: @access.version.name)
    end


    
  end
end
