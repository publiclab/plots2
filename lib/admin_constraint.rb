class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_credentials_id]
    user = User.find request.session[:user_credentials_id]
    user && user.admin?
  end
end
