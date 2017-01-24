# config/initializers/recaptcha.rb
if Rails.env == "production"
  Recaptcha.configure do |config|
    config.site_key  = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'
    config.secret_key = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'
    # Uncomment the following line if you are using a proxy server:
    # config.proxy = 'http://myproxy.com.au:8080'
  end
end
