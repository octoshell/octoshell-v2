require 'main_spec_helper'
module Core
  describe Mailer, type: :mailer do
    describe '#invitation_to_octoshell' do
      it 'sends emails with :ru param' do
        @project = create_project
        @invitation = @project.invitations.create_with(language: 'ru')
                              .find_or_create_by!(user_email: "octo@octo.ru",
                                                  user_fio: "Ivan Ivan Ivan")
				expect(ActionMailer::Base.deliveries.last.subject).to eq "Приглашение в проект «#{@project.title}» в системе Octoshell"
      end

			it 'sends emails with :en param' do
        @project = create_project
        @invitation = @project.invitations.create_with(language: 'en')
                              .find_or_create_by!(user_email: "octo@octo.ru",
                                                  user_fio: "Ivan Ivan Ivan")
				expect(ActionMailer::Base.deliveries.last.subject).to eq "The invitation to the \"#{@project.title}\" project in \"Octoshell\" system"
      end


    end

  end
end
