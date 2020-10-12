require "application_system_test_case"

class SettingsTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "jeff")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()
  end

  test 'viewing the settings page' do
    visit '/settings'

    take_screenshot
  end

  test 'notification settings are working correctly' do
    visit '/settings'

    # Enable "Notifcation when you are mentioned"
    find('input[name="notifications:mentioned"] ~ span').click()
    # Enable "Browser notification for all"
    find('input[name="notifications:all"] ~ span').click()

    find('button#save', text: 'Save').click()

    # Wait for settings to update (POST request)
    wait_for_ajax

    # Make sure that success message appears
    assert_selector(".alert.alert-success", text: "×\nSettings updated successfully!")

    # Checkboxes are hidden and this rule needs to be disabled in order to fetch them
    Capybara.ignore_hidden_elements = false
    visit '/settings'

    notifications_mentioned_checkbox = find('input[name="notifications:mentioned"]')
    notifications_all_checkbox = find('input[name="notifications:all"]')

    # Make sure the updated settings are permanent
    assert_equal( notifications_mentioned_checkbox.checked?, true )
    assert_equal( notifications_all_checkbox.checked?, true )

    Capybara.ignore_hidden_elements = true
  end

end
