require "application_system_test_case"

class SpamTest < ApplicationSystemTestCase

  def setup
    visit "/"
    click_on "Login"
    fill_in 'user_session[username]', with: 'palpatine'
    fill_in 'user_session[password]', with: 'secretive'
    click_on "Log in"
  end

  test "Delete node in spam2" do
    spam_page = nodes(:first_timer_note)
    visit "/spam2"
    accept_confirm "Are you sure you want to delete #{spam_page.path}?" do
    find("a[href='/notes/delete/#{spam_page.id}'").click()
    end
    assert_selector('.noty_body', text: 'Node deleted')

  end

  test "publish node in spam2" do
    publish_page = nodes(:first_timer_note)
    visit "/spam2"
    find("a[href='/moderate/publish/#{publish_page.id}'").click()
    assert_selector('.noty_body', text: 'Node published')
  end

  test "spam post in spam2" do
    spam_page = nodes(:first_timer_note)
    visit "/spam2"
    find("a[href='/moderate/spam/#{spam_page.id}'").click()
    assert_selector('.noty_body', text: 'Node spammed')
  end

  test "unflag post in spam2" do
    flag_page = nodes(:about)
    visit "/spam2/flags"
      find("a[href='/moderate/remove_flag_node/#{flag_page.id}'").click()
      assert_selector('.noty_body', text: 'Node unflagged')
  end

  test "banning of a user in spam2" do
    ban_page = nodes(:first_timer_note)
    visit "/spam2"
    within "#n#{ban_page.id}" do
      find("a[href='/ban/#{ban_page.author.id}'").click()
    end
    visit "/"
    visit "/profile/#{ban_page.author.username}"
    assert find("div.alert", text: "That user has been banned.")
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/unban/#{ban_page.author.id}'"
  end

  test "batch spam nodes" do
    banned_page1 = nodes(:first_timer_note)
    banned_page2 = nodes(:first_timer_question)
    visit "/spam2"
    # Click on the checkboxes of unmoderated nodes
    within "#n#{banned_page1.id}" do
      find(".selectedId").click()
    end
    within "#n#{banned_page2.id}" do
      find(".selectedId").click()
    end
    find("#batch-spam").click()
    page.assert_selector "div.alert-success"
    #check if author is banned
    visit "/profile/#{banned_page1.author.username}"
    assert find("div.alert", text: "That user has been banned.")
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/unban/#{banned_page1.author.id}'"
    visit "/profile/#{banned_page2.author.username}"
    assert find("div.alert", text: "That user has been banned.")
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/unban/#{banned_page2.author.id}']"
  end

  test "Batch publish nodes" do
    page1 = nodes(:first_timer_note)
    page2 = nodes(:first_timer_question)
    visit "/spam2"
    within "#n#{page1.id}" do
      find(".selectedId").click()
    end
    within "#n#{page2.id}" do
      find(".selectedId").click()
    end
    find("#batch-publish").click()
    page.assert_selector "div.alert-success"
    visit "/profile/#{page1.author.username}"
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/ban/#{page1.author.id}'"
    visit "/profile/#{page2.author.username}"
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/ban/#{page2.author.id}'"
  end

  test "batch delete nodes" do
    page1 = nodes(:first_timer_note)
    page2 = nodes(:first_timer_question)
    visit "/spam2"
    within "#n#{page1.id}" do
      find(".selectedId").click()
    end
    within "#n#{page2.id}" do
      find(".selectedId").click()
    end
    find("#delete-batch").click()
    assert_selector('div.alert', text: '2 nodes deleted')
  end

  test "Batch ban and batch unban" do
    page1 = nodes(:first_timer_note)
    page2 = nodes(:first_timer_question)
    visit "/spam2"
    within "#n#{page1.id}" do
      find(".selectedId").click()
    end
    within "#n#{page2.id}" do
      find(".selectedId").click()
    end
    find("#batch-ban").click()
    assert_selector('div.alert', text: '2 users banned.')
    visit "/profile/#{page1.author.username}"
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/unban/#{page1.author.id}'"
    visit "/profile/#{page2.author.username}"
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/unban/#{page2.author.id}'"

    visit "/spam2"
    within "#n#{page1.id}" do
      find(".selectedId").click()
    end
    within "#n#{page2.id}" do
      find(".selectedId").click()
    end
    find("#batch-unban").click()
    assert_selector('div.alert', text: '2 users unbanned.')
    visit "/profile/#{page1.author.username}"
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/ban/#{page1.author.id}'"
    visit "/profile/#{page2.author.username}"
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/ban/#{page2.author.id}'"
  end

  test "select count" do
    page1 = nodes(:first_timer_note)
    page2 = nodes(:first_timer_question)
    visit "/spam2"
    within "#n#{page1.id}" do
      find(".selectedId").click()
    end
    within "#n#{page2.id}" do
      find(".selectedId").click()
    end
    assert_selector('#select-count', text: '2')
  end

  test "unflag post in spam2/comments" do
    flag_comment= comments(:spam_comment)
    visit "/spam2/comments/filter/flagged/30"
      find("a[href='/moderate/remove_flag_comment/#{flag_comment.id}'").click()
      assert_selector('.noty_body', text: 'Comment unflagged')
  end
end