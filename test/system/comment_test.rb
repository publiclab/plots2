require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

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
    # assert_selector('h1', text: "Dashboard")

    visit nodes(:blog).path

    # we could see if an image gets created:
    # assert_no_difference 'Image.count' do

      # note this would be more complex with more than one comment bc of "reply" form
      attach_file('fileinput', "#{Rails.root.to_s}/public/images/pl.png", visible: false)

    # end

    wait_for_ajax # wait for it to upload and re-appear
    assert_selector('textarea#text-input', text: '![](/some/imageid.png)')

    # click_button 'Preview'
    # assert_equal 1, page.evaluate_script("$('.comment-form div#preview').is(':visible')")

    click_button 'Publish'

    assert_selector('.comment-form textarea#text-input', text: '') # the textarea should clear

    # assert some javascript:
    # assert_equal 1, page.evaluate_script("$('.typeahead.dropdown-menu').find('li').length")

  end
end

# https://stackoverflow.com/questions/36536111/waiting-for-ajax-with-capybara-poltergeist
def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop until finished_all_ajax_requests?
  end
end

def finished_all_ajax_requests?
  request_count = page.evaluate_script("$.active").to_i
  request_count && request_count.zero?
rescue Timeout::Error
end
