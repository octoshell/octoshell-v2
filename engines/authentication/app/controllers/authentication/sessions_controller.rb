class Authentication::SessionsController < Authentication::ApplicationController
  before_filter :handle_authorized, if: :logged_in?, except: :destroy

  def new
    @user = User.new
  end

  def create
    email, password, remember = fetch_user(params[:user])
    if @user = login(email, password, remember)
      redirect_back_or_to(root_url)
    else
      User.extend(Authentication::UserWithAuthErrors)
      @user = User.initialize_with_auth_errors(email)
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new
    end
  end

  def destroy
    logout
    redirect_to main_app.root_path
  end

  private

  def handle_authorized
    redirect_to main_app.root_path
  end

  def fetch_user(hash)
    [hash[:email], hash[:password], hash[:remember]]
  end
end
