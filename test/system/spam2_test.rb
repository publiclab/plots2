require "application_system_test_case"

class SpamTest < ApplicationSystemTestCase

  def setup
    visit "/"
    click_on "Login"
    fill_in 'user_session[username]', with: 'palpatine'
    fill_in 'user_session[password]', with: 'secretive'
    click_on "Log in"
  end

  test "Delete post in spam2" do
    spam_page = nodes(:one)
    visit spam_page.path
    first("span[data-original-title='Tools']").click()
    click_on "Spam"
    visit "/spam2"
    accept_confirm 'Are you sure you want to delete "'+spam_page.path+'"?' do
    find("a[href='/notes/delete/#{spam_page.id}'").click()
    end
    assert_selector('div.alert', text: 'Node Deleted')
  end
end
