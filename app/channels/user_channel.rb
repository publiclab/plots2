class UserChannel < ApplicationCable::Channel
  def subscribed
    if !current_user.nil?
      stream_from "users:#{current_user.id}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
