require "application_system_test_case"

class ModerationTest < ApplicationSystemTestCase

  def setup
    visit "/"
    find(".nav-link.loginToggle").click()

    fill_in 'user_session[username]', with: 'palpatine'
    fill_in 'user_session[password]', with: 'secretive'
    find(".login-modal-form #login-button").click()

  end

  test "banning and unbanning a user" do
    visit "/profile/#{users(:bob).username}"

    find("a#info-ellipsis").click
    accept_confirm "Are you sure? The user will no longer be able to log in or publish, and their content will be hidden." do
      find("a[href='/ban/#{users(:bob).id}'").click()
    end
    assert find("div.alert", text: "That user has been banned.")

    find("a#info-ellipsis").click
    find("a[href='/unban/#{users(:bob).id}'").click()
    assert find("div.alert", text: "The user has been unbanned.")
  end

  test "moderating and unmoderating a user" do
    visit "/profile/#{users(:bob).username}"

    find("a#info-ellipsis").click()
    accept_confirm "Are you sure? The user will no longer be able to log in or publish." do
      find("a[href='/admin/moderate/#{users(:bob).id}'").click()
    end
    assert find("div.alert", text: "That user has been placed in moderation.")

    find("a#info-ellipsis").click()
    find("a[href='/admin/unmoderate/#{users(:bob).id}'").click()
    assert find("div.alert", text: "The user has been unmoderated.")
  end

  test "batch-spamming users" do
    banned_page = nodes(:spam_targeted_page)
    banned_page2 = nodes(:wiki_page)
    visit "/spam/batch/#{banned_page.id},#{banned_page2.id}"
    page.assert_selector "div.alert-success"

    # verify pages are spammed
    visit banned_page.path
    assert find("div.alert", text: "That page has been moderated as spam. Please contact web@publiclab.org if you believe there is a problem.")

    visit banned_page2.path
    assert find("div.alert", text: "That page has been moderated as spam. Please contact web@publiclab.org if you believe there is a problem.")

    # verify note authors are banned
    visit "/"
    visit "/profile/#{banned_page.author.username}"
    assert find("div.alert", text: "That user has been banned.")
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/unban/#{banned_page.author.id}'"

    visit "/profile/#{banned_page2.author.username}"
    assert find("div.alert", text: "That user has been banned.")
    find("a#info-ellipsis").click()
    page.assert_selector "a[href='/unban/#{banned_page2.author.id}'"
  end
end
