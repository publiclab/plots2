require "application_system_test_case"

class TagTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()
  end

  test 'subscribing to a tag' do
    visit '/tag/nature'

    # Click on 3 dots menu
    find('.tag-header .pull-right').click()

    # Subscribe to the tag "nature"
    find('.dropdown-menu.show a[href="/subscribe/tag/nature"]').click()

    # Make sure that success message appears
    assert_selector(".alert.alert-success", text: "×\nYou are now following 'nature'.")

    # Verify that tag exists in users's tags subscriptions table
    assert_selector('.table a[href="/tag/nature"]', text: "nature")
  end

  test 'unsubscribing from a tag' do
    visit '/subscriptions'

    # Subscribe to a tag
    find('.navbar-form input').set('oceans')
    find('.navbar-form button.add-subscriptions').click()

    wait_for_ajax

    # Unsubscribe from the tag "oceans"
    find('.table a[href="/unsubscribe/tag/oceans"]').click()

    wait_for_ajax

    # Make sure that success message appears
    assert_selector(".alert.alert-success", text: "×\nYou have stopped following 'oceans'.")

    # Verify the tag "oceans" is not present in the tag subscriptions table
    assert_selector('.table a[href="/tag/oceans"]', count: 0)
  end

end
