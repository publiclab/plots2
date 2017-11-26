require 'coveralls'
Coveralls.wear_merged!

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'authlogic/test_case'
require 'i18n'

#ActiveSupport::Inflector.inflections(:en) do |inflect|
#  inflect.irregular 'drupal_user', 'drupal_user'
#end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting

  # yay thanks: http://journal.missiondata.com/post/63405042042/rails-fixtures-with-models-using-settablename
  set_fixture_class rusers: "User"
  set_fixture_class users: "DrupalUser"
  set_fixture_class node_revisions: "Revision"
  set_fixture_class drupal_content_type_map: "DrupalContentTypeMap"

  fixtures :all

  # Add more helper methods to be used by all tests here...

  def request_host
    ActionMailer::Base.default_url_options[:host]
  end
end

def available_testing_locales
  I18n.available_locales
end
