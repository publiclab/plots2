module MiniTestWithBullet
  def before_setup
    Bullet.start_request
    super if defined?(super)
  end

  def after_teardown
    super if defined?(super)
    Bullet.perform_out_of_channel_notifications if Bullet.notification? 
    Bullet.end_request
  end
end
