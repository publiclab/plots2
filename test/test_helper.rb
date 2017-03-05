ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "authlogic/test_case"
require "i18n"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting

  # yay thanks: http://journal.missiondata.com/post/63405042042/rails-fixtures-with-models-using-settablename
  set_fixture_class :node => Node
  set_fixture_class :rusers => User
  set_fixture_class :users => DrupalUsers
  set_fixture_class :node_counter => DrupalNodeCounter
  set_fixture_class :node_revisions => DrupalNodeRevision
  set_fixture_class :tag_selection => TagSelection
  set_fixture_class :tags => Tag
  set_fixture_class :community_tags => DrupalNodeCommunityTag
  set_fixture_class :comments => Comment
  set_fixture_class :searches => SearchRecord
  
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def request_host
    ActionMailer::Base.default_url_options[:host]
  end

end

def available_testing_locales
  I18n.available_locales
end
