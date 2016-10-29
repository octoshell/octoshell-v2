class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find request.session[:user_id]
    user && user.extend(UserAbilities).ability.may?(:access, :admin)
  end
end
