require "application_system_test_case"

class ScreenshotsTest < ApplicationSystemTestCase
  Capybara.default_max_wait_time = 60

  test 'front' do
    visit '/'
    take_screenshot
  end

  test 'signup modal' do
    visit '/'
    find('.nav-link.signupToggle').click()
    assert_selector('#signupContainer', visible: true)
    take_screenshot
  end

  test 'signup modal form validation' do
    visit '/'
    find('.nav-link.signupToggle').click()

    fill_in 'user[username]', with: 'Bob'
    fill_in 'user[email]', with: 'Invalid@email'
    fill_in 'user[password]', with: 'short'
    fill_in 'user[password_confirmation]', with: 'password'

    username_error_msg = find("#username-signup ~ small").text
    email_error_msg = find("#email ~ small").text
    password_error_msg = find("#password1 ~ small").text
    confirm_password_error_msg = find("#password-confirmation ~ small").text

    assert_equal( username_error_msg, "Username already exists" )
    assert_equal( email_error_msg, "Invalid email" )
    assert_equal( password_error_msg, "Please make sure password is at least 8 characters long" )
    assert_equal( confirm_password_error_msg, "Password and Password Confirmation should be the same" )

    take_screenshot
  end

  test 'signup modal disabled submit button on empty username' do
    visit '/'
    find('.nav-link.signupToggle').click()

    fill_in 'user[username]', with: 'Bob'
    fill_in 'user[email]', with: 'valid@email.com'
    fill_in 'user[password]', with: 'password1'
    fill_in 'user[password_confirmation]', with: 'password1'

    fill_in 'user[username]', with: ''

    submitFormButton = find('#create-form button.btn-save')

    assert_equal submitFormButton.disabled?, true
    take_screenshot
  end

  test 'login modal' do
    visit '/'
    click_on 'Login'
    assert_selector('#loginContainer', visible: true)
    take_screenshot
  end

  test 'login modal form validation' do
    visit '/'
    click_on 'Login'

    fill_in 'user_session[username]', with: 'Bob'
    # The length of a password should be minimum 8 characters
    fill_in 'user_session[password]', with: 'invalid'

    click_on 'Log in'

    # Get the error message (remove '×' that closes the modal and remaining whitespaces)
    error_msg = find('.error-msg-container').text.gsub('×', '').strip()

    assert_equal( error_msg, 'Invalid username or password' )
    take_screenshot
  end

  test 'signup' do
    visit '/signup'
    take_screenshot
  end

  test 'login' do
    visit '/login'
    take_screenshot
  end

  test 'tags' do
    visit '/tags'
    take_screenshot
  end

  test "tag stats" do
    visit "/tag/#{node_tags(:awesome).name}/stats"
    take_screenshot
  end

  test 'tag page' do
    nodes(:activity).add_tag('pin:test', users(:bob)) # ensure a pinned note appears
    visit '/tag/test'
    assert_selector('i.fa-thumb-tack', visible: true) # check for pin icon
    take_screenshot
  end

  test 'profile page' do
    visit '/profile/bob'
    take_screenshot
  end

  test 'tag by author page' do
    visit '/tag/spectrometer/author/bob'
    take_screenshot
  end

  test 'tag wildcard' do
    visit '/tag/spect*'
    take_screenshot
  end

  test 'tag contributors page' do
    visit '/contributors/spectrometer'
    take_screenshot
  end

  test 'wiki' do
    visit '/wiki'
    take_screenshot
  end

  test 'stats' do
    visit '/stats'
    take_screenshot
  end

  test 'blog' do
    visit '/blog'
    take_screenshot
  end

  test 'people' do
    visit '/people'
    take_screenshot
  end

  test 'questions' do
    visit '/questions'
    take_screenshot
  end

  test 'questions_shadow' do
    visit '/questions_shadow'
    take_screenshot
  end

  test 'question page' do
    visit nodes(:question).path
    take_screenshot
  end

  test 'methods' do
    visit '/methods'
    take_screenshot
  end

  test 'comments' do
    visit '/comments'
    take_screenshot
  end

  test 'wiki revisions' do
    visit "/wiki/revisions/#{nodes(:about).slug}"
    click_on '2'
    take_screenshot
  end

  test 'wiki page with inline grids' do
    node = nodes(:place) # /wiki/chicago page
    node.add_tag('place', users(:bob)) # lets get a map on this page!
    node.add_tag('lon:-71.4', users(:bob))
    node.add_tag('lat:41.7', users(:bob))
    revision = node.latest
    revision.body = "Inline grids **with markdown** and `basics`:\n\n* one\n\n*two\n\n## Thumbnails\n\n[nodes:grid:test]\n\n## Nodes\n\n[nodes:test]\n\n## Notes\n\n[notes:test]\n\n## Wikis\n\n[wikis:test]\n\n## Questions\n\n[questions:test]\n\n## Activities\n\n[activities:test]\n\n## Thumbnails\n\n[notes:grid:test]\n\nThis should not render:\n\n`[nodes:tagname]`"
    revision.save
    visit node.path
    take_screenshot
  end

  test 'embeddable grids' do
    visit '/embed/grid/test'
    take_screenshot
  end

  test 'embeddable thumbnail grids' do
    visit '/embed/grid/grid:test'
    take_screenshot
  end

  test 'spam moderation page' do
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "obiwan") # moderator
    fill_in("password-signup", with: "secretive")
    click_on "Log in"
    visit '/spam'
    assert_selector('#batch-delete', visible: true)
    take_screenshot
  end

  test 'blog page with location modal' do
    visit '/'
    click_on 'Login'
    fill_in("username-login", with: "steff1")
    fill_in("password-signup", with: "secretive")
    click_on "Log in"
    visit nodes(:blog).path
    find('a#tags-open').click # open the tagging form
    find('a.blurred-location-input').click
    # click_on(class: 'blurred-location-input') # alternative
    # fill_in("placenameInput", with: "Pusan")
    take_screenshot
  end

  test 'mobile displays' do
    node = nodes(:place) # /wiki/chicago page
    revision = node.latest
    revision.body = '<iframe width="360px" height="1300px" src="/post"></iframe> '
    revision.body += '<iframe width="360px" height="1300px" src="/tag/babylegs"></iframe>'
    revision.save
    visit node.path
    take_screenshot
  end

  # test 'maps' do
  #   visit '/map/chicago'
  #   take_screenshot
  # end

end
