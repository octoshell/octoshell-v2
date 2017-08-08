module Pack
  class Mailer < ActionMailer::Base


    def email_vers_state_changed(id)
      @access=Access.find id
      get_receiver

      mail to: @receiver.email, subject: t(".subject",version_name: @access.version.name)
      

    end
    
   
    def access_changed(id,arg='no')
      @access=Access.find id

      get_receiver
      @status_info=if arg!='no'
        t("mailer_messages.#{arg}")
      
      else
        t("mailer_messages.#{@access.status}")
      end
      mail to: @receiver.email, subject: t("mailer_messages.subject",version_name: @access.version.name)
    end


     def get_receiver
      @receiver=if @access.who_type=='User'
        @access.who
      elsif @access.who_type=='Core::Project'
        @access.who.owner
      end
    end

    
  end
end
