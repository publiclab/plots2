require 'simplecov'
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'authlogic/test_case'
require 'i18n'
require 'mocha/minitest'
require 'webmock/minitest'
# require 'support/billy'

require "minitest/reporters"
MiniTest::Reporters.use! [MiniTest::Reporters::ProgressReporter.new,
                          MiniTest::Reporters::JUnitReporter.new]

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting

  # These can be replaced in Rails 5 with this syntax, in the fixture files:
  # https://github.com/rails/rails/commit/2acec4657752d441ab87b9f5862d7918843d6409#diff-1ed2907b3b8f148c2533558a77673ffaR3
  # _fixture:
  #   model_class: 'User'
  set_fixture_class users: User
  set_fixture_class node_tags: NodeTag
  set_fixture_class node_revisions: Revision

  fixtures :all

  # Add more helper methods to be used by all tests here...

  def request_host
    ActionMailer::Base.default_url_options[:host]
  end
end

def available_testing_locales
  I18n.available_locales
end

# used in comment_test.rb
def page_types
  {
    :note => :comment_note, 
    :question => :comment_question, 
    :wiki => :wiki_page
  }
end

WebMock.allow_net_connect!
WebMock.stub_request(:any, "publiclab.org/api/srch/nearbyPeople")
  .to_return(
    body: "{items:[]}",
    status: 200,
    :headers => {"Content-Type"=> "application/json"})