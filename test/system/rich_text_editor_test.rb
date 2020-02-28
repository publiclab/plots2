require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class RichTextEditorTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find('.nav-link.loginToggle').click()
    fill_in('username-login', with: 'jeff')
    fill_in('password-signup', with: 'secretive')

    find('.login-modal-form #login-button').click()
  end

  test 'thumbnail image drag and drop upload' do
    visit '/post'

    # Upload the image
    drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", '.ple-drag-drop')

    # Wait for image upload to finish
    wait_for_ajax

    is_image_url_undefined  = page.evaluate_script("$('.ple-drag-drop').attr('style').includes('url(\"undefined\"')")

    # Make sure that image has been uploaded
    assert_equal( is_image_url_undefined, false )
  end

  test 'main textarea image drag and drop upload' do
    visit '/post'

    # Upload the image
    drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", '.wk-container-drop')

    # Wait for image upload to finish
    wait_for_ajax

    # Make sure that image has been uploaded
    page.assert_selector('.wk-wysiwyg img', count: 1)
  end

end
