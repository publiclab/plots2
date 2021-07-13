Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!

  config.cache_classes = true

  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance
  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }
  
  config.active_record.sqlite3.represent_boolean_as_integer = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.raise_delivery_errors = false


  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.active_support.test_order = :sorted # or `:random` if you prefer

  config.action_mailer.default_url_options = {
    host: 'www.example.com'
  }

  config.active_job.queue_adapter = :inline

  OmniAuth.config.test_mode = true
  #OAuth hash for different providers for testing purpose
  #Google Provider
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      'provider' => 'google_oauth2',
      'uid' => '1357908642',
      'info' => {
        'name' => 'sidharth bansal',
        'email' => 'bansal.sidharth309@gmail.com'
      }
    })

  OmniAuth.config.mock_auth[:google_oauth2_2] = OmniAuth::AuthHash.new({
       'provider' => 'google_oauth2',
       'uid' => '1357908642',
       'info' => {
         'name' => 'jeff',
         'email' => 'jeff@pxlshp.com'
       }
     })
  #Github Provider
  OmniAuth.config.mock_auth[:github1] = OmniAuth::AuthHash.new({
      'provider' => 'github',
      'uid' => '135790579602',
      'info' => {
        'name' => 'sidharth bansal',
        'email' => 'bansal.sidharth309@gmail.com'
      }
    })

  OmniAuth.config.mock_auth[:github2] = OmniAuth::AuthHash.new({
      'provider' => 'github',
      'uid' => '1357998009602',
      'info' => {
        'name' => 'jeffrey',
        'email' => 'jeff@pxlshp.com'
        }
    })

  OmniAuth.config.mock_auth[:github3] = OmniAuth::AuthHash.new({
      'provider' => 'github',
      'uid' => '135799239602',
      'info' => {
        'name' => 'emila buffet',
        'email' => 'emila.buffet309@gmail.com'
      }
    })

  # This config is has the same email as one of the fixture users. When it is used to login, instead of signing up a new user
  # it should link this oauth config to the fixture user.
  OmniAuth.config.mock_auth[:github4] = OmniAuth::AuthHash.new({
      'provider' => 'github',
      'uid' => '135799134741',
      'info' => {
        'name' => 'Bob',
        'email' => 'bob@publiclab.org'
      }
    }) 
    #facebook Provider
    OmniAuth.config.mock_auth[:facebook1] = OmniAuth::AuthHash.new({
        'provider' => 'facebook',
        'uid' => '1357905002',
        'info' => {
          'name' => 'sidharth bansal',
          'email' => 'bansal.sidharth309@gmail.com'
        }
      })

    #Twitter Provider
    OmniAuth.config.mock_auth[:twitter1] = OmniAuth::AuthHash.new({
        'provider' => 'twitter',
        'uid' => '135798079602',
        'info' => {
          'name' => 'sidharth bansal',
          'email' => 'bansal.sidharth309@gmail.com'
        }
      })

      OmniAuth.config.mock_auth[:facebook2] = OmniAuth::AuthHash.new({
          'provider' => 'facebook',
          'uid' => '1359988009602',
          'info' => {
            'name' => 'jeffrey',
            'email' => 'jeff@pxlshp.com'
            }
        })

      OmniAuth.config.mock_auth[:facebook3] = OmniAuth::AuthHash.new({
          'provider' => 'facebook',
          'uid' => '13579992302',
          'info' => {
            'name' => 'emila buffet',
            'email' => 'emila.buffet309@gmail.com'
          }
      })

    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new({
        'provider' => 'twitter',
        'uid' => '137898009602',
        'info' => {
          'name' => 'jeffrey',
          'email' => 'jeff@pxlshp.com'
          }
      })

    OmniAuth.config.mock_auth[:twitter3] = OmniAuth::AuthHash.new({
        'provider' => 'twitter',
        'uid' => '135689602',
        'info' => {
          'name' => 'emila buffet',
          'email' => 'emila.buffet309@gmail.com'
        }
      })
  
  
  # This config is has the same email as one of the fixture users. When it is used to login, instead of signing up a new user
  # it should link this oauth config to the fixture user.
  OmniAuth.config.mock_auth[:facebook4] = OmniAuth::AuthHash.new({
      'provider' => 'facebook',
      'uid' => '135799134741',
      'info' => {
        'name' => 'Bob',
        'email' => 'bob@publiclab.org'
      }
    }) 
  
  
  # This config is has the same email as one of the fixture users. When it is used to login, instead of signing up a new user
  # it should link this oauth config to the fixture user.
  OmniAuth.config.mock_auth[:twitter4] = OmniAuth::AuthHash.new({
      'provider' => 'twitter',
      'uid' => '135799134741',
      'info' => {
        'name' => 'Bob',
        'email' => 'bob@publiclab.org'
      }
    }) 
  
  
  # This config is has the same email as one of the fixture users. When it is used to login, instead of signing up a new user
  # it should link this oauth config to the fixture user.
  OmniAuth.config.mock_auth[:google_oauth2_4] = OmniAuth::AuthHash.new({
      'provider' => 'google_oauth2',
      'uid' => '135799134741',
      'info' => {
        'name' => 'Bob',
        'email' => 'bob@publiclab.org'
      }
    }) 
  
  
  # Twitter Provider with no email provided
  OmniAuth.config.mock_auth[:twitter_no_email] = OmniAuth::AuthHash.new({
      'provider' => 'twitter',
      'uid' => '135798079602',
      'info' => {
        'name' => 'jeff with no email',
      }
    })
end
