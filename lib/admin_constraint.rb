class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]

    user = User.find request.session[:user_id]
    user && Ability.new(user).can?(:access, :admin)
  end
end
