require 'rails_email_preview'
#= REP hooks and config
RailsEmailPreview.setup do |config|
#
#  # hook before rendering preview:
#  config.before_render do |message, preview_class_name, mailer_action|
#    # Use roadie-rails:
#    Roadie::Rails::MailInliner.new(message, message.roadie_options).execute
#    # Use premailer-rails:
#    Premailer::Rails::Hook.delivering_email(message)
#    # Use actionmailer-inline-css:
#    ActionMailer::InlineCssHook.delivering_email(message)
#  end
#
#  # do not show Send Email button
 config.enable_send_email = false
#
#  # You can specify a controller for RailsEmailPreview::ApplicationController to inherit from:
 # config.parent_controller = '::Admin::ApplicationController'
end
#
#= REP + Comfortable Mexican Sofa integration
#
# # enable comfortable_mexican_sofa integration:
# require 'rails_email_preview/integrations/comfortable_mexica_sofa'

Rails.application.config.to_prepare do
  # Render REP inside a custom layout (set to 'application' to use app layout, default is REP's own layout)
  # This will also make application routes accessible from within REP:
  RailsEmailPreview.layout = 'layouts/application'
  # RailsEmailPreview.parent_controller = 'Admin::ApplicationController'
  # Set UI locale to something other than :en
  RailsEmailPreview.locale = :ru
  RailsEmailPreview::ApplicationController.module_eval do
    before_action :check_rep_permissions
    private

    def check_rep_permissions
      if User.superadmins.exclude? current_user
        raise CanCan::AccessDenied
      end
    end
  end

  # Auto-load preview classes from:
  RailsEmailPreview.preview_classes = RailsEmailPreview.find_preview_classes('app/mailer_previews')
end
