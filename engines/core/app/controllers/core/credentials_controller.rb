module Core
  class CredentialsController < Core::ApplicationController
    before_action only: :deactivate do
      @credential = Credential.find(params[:credential_id])
      not_authorized unless @credential.user_id == current_user.id
    end


    def new
      @credential = current_user.credentials.build
    end

    def create
      @credential = current_user.credentials.build(credential_params)
      if @credential.activate_or_create
        redirect_to main_app.profile_path
      else
        render :new
      end
    end

    def deactivate
      if @credential.deactivate!
        @credential.save
        redirect_to main_app.profile_path
      else
        flash.now[:alert] = @credential.errors.full_messages.join(', ')
        render :show
      end
    end

    private

    def credential_params
      params.require(:credential).permit(:name, :public_key_file, :public_key)
    end
  end
end
