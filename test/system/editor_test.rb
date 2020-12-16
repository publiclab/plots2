require "application_system_test_case"

class EditorTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'
    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "palpatine")
    fill_in("password-signup", with: "secretive")
    find(".login-modal-form #login-button").click()
  end

#   test "check that rich wiki editor functions correctly" do
#     visit "/wiki/wiki-page-path"
#     find("a[data-original-title='Try the beta inline Rich Wiki editor.'").click()
#     first("div.inline-section").hover()

#     # click edit btn
#     using_wait_time(2) { first("a.inline-edit-btn").click() }

#     find("div.wk-wysiwyg").set("wiki text")

#     click_on "Save"
#     page.assert_selector("p", text: "wiki text")
#   end

#   test "check that markdown wiki editor functions correctly" do
#     visit "/wiki/wiki-page-path"
#     find("a[data-original-title='Edit this wiki page.'").click()

#     find("#text-input").set("wiki text")
#     find("a#publish").click()

#     page.assert_selector("p", text: "wiki text")
#   end

#   test "check rich editor features are functional" do
#     visit "/wiki/wiki-page-path"
#     find("a[data-original-title='Try the beta inline Rich Wiki editor.'").click()
#     first("div.inline-section").hover()

#     using_wait_time(2) { first("a.inline-edit-btn").click() }

#     # test the following features
#     ["bold", "italic", "code", "heading"].each do |element|
#       # clicking on the button generates the element with dummy text
#       find("button.woofmark-command-#{element}").click()
#       # these keys are called to deselect the previous elements
#       find("div.wk-wysiwyg").native.send_key(:arrow_left, :enter)
#     end

#     click_on "Save"

#     # assert that the features have worked and that the correct wiki elements are displayed
#     page.assert_selector("strong", text: "strong text")
#     page.assert_selector("h1", text: "Heading Text")
#     page.assert_selector("em", text: "emphasized text")
#     page.assert_selector("code", text: "code goes here")
#   end

#   test "check markdown editor features are functional" do
#     visit "/wiki/wiki-page-path"
#     find("a[data-original-title='Edit this wiki page.']").click()

#     # test the following features
#     ["**strong text**", "_emphasized text_", "`code goes here`", "# Heading Text"].each do |element|
#       find("#text-input").native.send_keys(element)
#       find("#text-input").native.send_keys(:enter)
#     end

#     find("a#publish").click()

#     # assert that the features have worked and that the correct wiki elements are displayed
#     page.assert_selector("strong", text: "strong text")
#     page.assert_selector("h1", text: "Heading Text")
#     page.assert_selector("em", text: "emphasized text")
#     page.assert_selector("code", text: "code goes here")
#   end
end
