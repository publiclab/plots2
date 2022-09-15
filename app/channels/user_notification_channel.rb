class UserNotificationChannel < ApplicationCable::Channel
  def subscribed 
    if current_user.nil?
      reject
    else
      stream_from "users:notification:#{current_user.id}"
    end
  end
 

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
