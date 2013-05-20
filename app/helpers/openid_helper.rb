
module OpenidHelper

  def url_for_user
    "/profile/"+ current_user.username
  end

end

