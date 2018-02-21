This application uses RECAPTCHA via the recaptcha gem in production only. To configure, please set your API keys in /config/initializers/recaptcha.rb:

https://github.com/ambethia/recaptcha#recaptchaconfigure

The default we're using is:

```ruby
# config/initializers/recaptcha.rb
if Rails.env == "production"
  Recaptcha.configure do |config|
    config.site_key  = 'SITE_KEY_HERE'
    config.secret_key = 'SECRET_KEY_HERE'
    # Uncomment the following line if you are using a proxy server:
    # config.proxy = 'http://myproxy.com.au:8080'
  end
end
```

