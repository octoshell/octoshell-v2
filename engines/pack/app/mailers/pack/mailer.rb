module Pack
  class Mailer < ActionMailer::Base
    helper_method :receiver, :to
    # before_action only: %w[requested allowed denied expired deleted].map { |s| "access_changed_#{s}"} do
    #   @link_for_to = link_to @access.to, @access.to
    # end

    # state :requested, initial: true
    # state :allowed
    # state :denied
    # state :expired
    # state :deleted
    def version_state_changed(id, version_id)
      @access = Access.find id
      @version = Version.find(version_id)
      mail to: receiver.email, subject: t('.subject', version_name: @version.name)
    end

    def access_changed(id, arg = 'no')
      @access = Access.find id
      get_receiver
      @status_info = if arg == 'no'
        t("mailer_messages.#{@access.status}")
      else
        t("mailer_messages.#{arg}")
      end
      mail to: @receiver.email, subject: t("mailer_messages.subject", to: @access.to.to_s)
    end

    %w[allowed denied expired deleted end_lic denied_longer].map { |s| "access_changed_#{s}"}
                                      .each  do |method|
      define_method(method) do |id|
        # ::Pack::Mailer.public_send(method, Pack::Access.first.id)
        @access = Access.find id
        mail to: receiver.email, subject: t('.subject', to: to(@access.to))
      end
    end


    # def access_changed_allowed(id)
    #   @access = Access.find id
    #   mail to: receiver.email, subject: t('.subject', to: to(@access.to))
    # end
    #
    # def access_changed_denied(id)
    #   @access = Access.find id
    #   mail to: receiver.email, subject: t('.subject', to: to(@access.to))
    # end
    #
    # def access_changed_expired(id)
    #   @access = Access.find id
    #   mail to: receiver.email, subject: t('.subject', to: to(@access.to))
    # end
    #
    # def access_changed_deleted(id)
    #   @access = Access.find id
    #   mail to: receiver.email, subject: t('.subject', to: to(@access.to))
    # end


    private

    def receiver
      if @access.who_type == 'User'
        @access.who
      elsif @access.who_type == 'Core::Project'
        @access.who.owner
      end
    end

    def to(model)
      # to_version: Версии %{to}
      # to_package: Пакету %{to}

      if model.is_a? Pack::Version
        t('pack.mailer.to_version', to: model.name)
      else
        t('pack.mailer.to_package', to: model.name)
      end
    end

     def get_receiver
       @receiver = if @access.who_type == 'User'
                    @access.who
                   elsif @access.who_type == 'Core::Project'
                    @access.who.owner
                   end
      @user = @receiver
     end

    def receiver
      if @access.who_type == 'User'
        @access.who
      elsif @access.who_type == 'Core::Project'
        @access.who.owner
      end
   end

  end
end
