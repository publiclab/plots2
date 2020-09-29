require "application_system_test_case"
# https://guides.rubyonrails.org/testing.html#implementing-a-system-test

class PostTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  Capybara.default_max_wait_time = 60

  def setup
    visit '/'

    find(".nav-link.loginToggle").click()
    fill_in("username-login", with: "palpatine")
    fill_in("password-signup", with: "secretive")

    find(".login-modal-form #login-button").click()
  end

  test 'posting from the editor' do
    visit '/post'

    fill_in("title-input", with: "My new post")

    el = find(".wk-wysiwyg") # rich text input
    el.set("All about this interesting stuff")


    find('.ple-publish').click()

    assert_selector('h1', text: "My new post")
    assert_selector('#content', text: "All about this interesting stuff")
    assert_selector('.alert-success', text: "×\nResearch note published. Get the word out on the discussion lists!")
  end

  test 'adding tags to the post' do
    visit '/wiki/wiki-page-path/comments'

    find('a#tags-open').click()

    find('.tag-input').set('nature').native.send_keys(:return)
    find('.tag-input').set('mountains').native.send_keys(:return)

    # Make sure that the 2 tags are added
    page.assert_selector('.tags-list p.badge', :count => 2)
  end

  test 'removing tags from the post' do
    visit '/wiki/organizers'

    find('a#tags-open').click()

    # There should be 1 tag that shows up as a badge and 2 as a card
    page.assert_selector('.tags-list .card-body', :count => 2)
    page.assert_selector('.tags-list p.badge', :count => 1)

    accept_alert do
      find('.tags-list p.badge .tag-delete').click()
    end
    
    # Make sure that 1 of the 3 tags is removed
    page.assert_selector('.tags-list p.badge', :count => 0)
  end

  test 'like button on the post' do
    visit '/wiki/wiki-page-path/comments'

    like_button = find('.btn-like').click();

    # Make sure that star is toggled
    assert has_no_selector?('.btn-like .fa.fa-star-o')
  end

  # Utility methods:

  def assert_page_reloads(message = "page should reload")
    page.evaluate_script "document.body.classList.add('not-reloaded')"
    yield
    if has_selector? "body.not-reloaded"
      assert false, message
    end
  end

  def assert_page_does_not_reload(message = "page should not reload")
    page.evaluate_script "document.body.classList.add('not-reloaded')"
    yield
    unless has_selector? "body.not-reloaded"
      assert false, message
    end
    page.evaluate_script "document.body.classList.remove('not-reloaded')"
  end

  test "edit wiki" do
    visit '/wiki/wiki-page-path/'

    find('a.btn-circle:first-of-type .fa-pencil').click()
    fill_in("body", with: "Test for editing wikis!")

    # preview edits
    find("a.preview-btn").click()
    assert find("p", text: "Test for editing wikis!")

    # publish edits
    find("#publish").click()
    assert find("p", text: "Test for editing wikis!")
    assert find("div.alert-success", text: "Edits saved.")
  end

  test 'drag and drop image upload to wiki post editor' do
    Capybara.ignore_hidden_elements = false
    visit '/wiki/new'

    # Upload the image
    drop_in_dropzone("#{Rails.root.to_s}/public/images/pl.png", ".dropzone")

    # Wait for image upload to finish
    wait_for_ajax
    Capybara.ignore_hidden_elements = true

    # Toggle preview
    find('.preview-btn').click()

    # Make sure that image has been uploaded
    page.assert_selector('#preview img', count: 1)
  end

  test "changing and reverting versions works correctly for wiki" do
    visit '/wiki/wiki-page-path/'

    # save text of wiki before edit
    old_wiki_content = find("#content p").text

    find("a#edit-btn").click()
    find("#text-input").set("wiki text")
    find("a#publish").click()

    # view wiki
    current_wiki_content = find("#content p").text
    # make sure edits worked and text is different
    assert current_wiki_content != old_wiki_content

    find("a[data-original-title='View all revisions for this page.']").click()

    accept_confirm "Are you sure?" do
      # revert to the previous version of wiki
      find('#row0 .btn-revert').click()
    end

    wiki_content = find("#content p").text

    # check old wiki content is the same as current content after revert
    # assert old_wiki_content == wiki_content
  end

  test "revision diff is displayed when comparing versions" do
    wiki = nodes(:wiki_page)

    visit wiki.path

    find("a#edit-btn").click()
    find("#text-input").native.send_keys(:enter, :enter, "wiki text")
    find("a#publish").click()

    find("a[data-original-title='View all revisions for this page.']").click()

    # verify additions are displayed as green `<ins>` tags
    page.assert_selector("ins", text: "<p>wiki")
    page.assert_selector("ins", text: "text</p>")
  end

  test 'following the wiki author' do
    visit '/wiki/wiki-page-path/'

    find('#menu-btn').click()

    find('#menu-follow-btn').click()

    page.execute_script <<-JS
      var popup = $('.popover-body')[1]
      var user_link = $(popup).find('a.btn')

      $(user_link).click()
    JS

    message = find('.alert-success', match: :first).text

    assert_equal( "×\nYou have started following Bob", message)
  end

  test 'adding a location to the wiki' do
    visit '/wiki/wiki-page-path/'

    # Toggle "Add location" modal
    find('a.btn-location').click()

    # Enter a location
    find('#map_content #coord_button').click()
    find('#map_content #lat').set("22")
    find('#map_content #lng').set("76")

    # Save the location
    find('#blurred-location-modal .btn-primary').click()

    # Wait for the location to be added
    wait_for_ajax

    # there should also be a page reload now, because we want to reload to see the sidebar mini-map
    find('a#tags-open').click()

    # Make sure proper latitude and longitude tags are added
    assert_selector('.tags-list .badge a[href="/tag/lat:22"]', text: "lat:22")
    assert_selector('.tags-list .badge a[href="/tag/lon:76"]', text: "lon:76")
  end

  test 'deleting a wiki' do
    visit '/wiki/wiki-page-path/'

    find('#menu-btn').click()

    accept_confirm "All revisions will be lost, and you cannot undo this action. If this is a spam page, be sure that it did not overwrite valid content before deleting the entire page and the history." do
      find('#menu-delete-btn').click()
    end

    message = find('.alert-success', match: :first).text

    assert_equal( "×\nContent deleted.", message )
  end

  test "awarding barnstar functions correctly" do
    note = nodes(:one)
    visit note.path

    find("span[data-original-title='Tools']").click()
    find("input[value='Give']").click()

    page.assert_selector("div.alert-success", text: "You awarded the basic barnstar to #{note.author.name}")
    page.assert_selector("p", text: "#{note.author.name} was awarded the Basic Barnstar by palpatine for their work in this research note.")
    page.assert_selector(".comment-body p", text: "@palpatine awards a barnstar to #{note.author.name} for their awesome contribution!")
  end

end
