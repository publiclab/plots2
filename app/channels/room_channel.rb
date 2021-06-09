# This is a general channel connected to all active session
class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(message)
    return unless current_user && current_user.admin?

    ActionCable.server.broadcast 'room_channel', message: message["message"]
  end
end
