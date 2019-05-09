require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 8

  def setup
    activate_authlogic
  end

  test 'adding an image into a comment box' do

    # log in
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "Bob")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"
    assert_selector('h1', text: "Dashboard")

    visit nodes(:blog).path

    # we could see if an image gets created:
    # assert_no_difference 'Image.count' do

      # could try this too:
      #within('comment-form') do
      #  click_link('choose one')
      #end

      # note this would be more complex with more than one comment bc of "reply" form
      attach_file('fileinput', "#{Rails.root.to_s}/public/images/pl.png", visible: false)

    # end

    #within('comment-form') do
    #end

    assert_selector('textarea#textinput', text: '![](/some/imageid.png)', wait: 12)

    # click_button 'Preview'
    # assert_equal 1, page.evaluate_script("$('.comment-form div#preview').is(':visible')")

    click_button 'Publish'

    assert_selector('.comment-form textarea#textinput', text: '')

    # assert some javascript:
    # assert_equal 1, page.evaluate_script("$('.typeahead.dropdown-menu').find('li').length")
  end
end
