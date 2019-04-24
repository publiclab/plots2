require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class SearchTest < ApplicationSystemTestCase

  def setup
    activate_authlogic
  end

  test 'adding an image into a comment box' do
    UserSession.create(users(:bob)) # log in

    visit nodes(:blog).path

    # we could see if an image gets created:
    # assert_no_difference 'Image.count' do
      attach_file('fileinput', 'public/images/pl.png')
    # end

    assert_selector('.comment-form textarea#textinput', text: '![](/some/imageid.png)')

    # click_button 'Preview'
    # assert_equal 1, page.evaluate_script("$('.comment-form div#preview').is(':visible')")

    click_button 'Publish'

    assert_selector('.comment-form textarea#textinput', text: '')

    # assert some javascript:
    # assert_equal 1, page.evaluate_script("$('.typeahead.dropdown-menu').find('li').length")
  end
end
