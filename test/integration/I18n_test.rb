require 'test_helper'
require 'sanitize'

class I18nTest < ActionDispatch::IntegrationTest

  test 'should choose i18n-locale for header partial' do
    available_testing_locales.each do |lang|
      # This test could use a rewrite. Two `get`s in succession?
      # get '/home'
      # get '/change_locale/' + lang.to_s
      # follow_redirect!
      # assert_select 'p[class=facebook-summary]', I18n.t('layout._header.summary')
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      get '/dashboard', params: { locale: lang }
      assert_select 'a[href=?]', '/dashboard'
    end
  end

  test 'should get change_locale path and set locale' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!
      assert_equal lang.to_s, I18n.locale.to_s
      get '/dashboard'
      follow_redirect!
      assert_equal lang.to_s, I18n.locale.to_s
    end
  end

  test 'should set default_locale for an unavailable locale' do
    get '/change_locale/' + 'unavail_locale'.to_s
    follow_redirect!
    assert_equal I18n.locale.to_s, I18n.default_locale.to_s
  end

  test 'should choose i18n for subscriptions' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      get '/subscriptions'
      assert_select 'b', I18n.t('home.subscriptions.title')
    end
  end

  test 'should choose i18n for dashboard/_activity' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      assert_select 'h3', I18n.t('dashboard._activity.activity')
    end
  end

  test 'should choose i18n for dashboard/_header' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      assert_select 'h1', I18n.t('dashboard._header.dashboard')
    end
  end

  test 'should choose i18n for dashboard/_node_comment' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      get '/dashboard'
      assert_select 'span', I18n.t('dashboard._node_comment.commented_on')
    end
  end

  test 'should choose i18n for dashboard/_node_moderate' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      post '/notes/create',
          params: {
           title: 'Some post',
           body: 'Some post body',
           tags: 'Some-tag',
           status: 4
          }
      get '/dashboard'
      assert_select 'a[class=?]', 'btn btn-outline-secondary btn-sm', I18n.t('dashboard.moderate.approve')
    end
  end

  test 'should choose i18n for dashboard/_node_question' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      post '/notes/create',
          params: {
           title: 'Some question',
           tags: 'question',
           status: 1
          }
      get '/dashboard'
      assert_select 'a[class=?]', 'btn btn-outline-secondary btn-sm float-right respond answer', I18n.t('dashboard._node_question.post_answer')
    end
  end

  test 'should choose i18n for dashboard/_node_wiki' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      post '/notes/create',
          params: {
           title: 'Some topic',
           tags: 'some-tag',
           type: 'page',
           status: 1
          }
      get '/dashboard'
      assert_select 'span', I18n.t('dashboard._node_wiki.new_page_by')
    end
  end

  test 'should choose i18n for dashboard/_wiki' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!
      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!
      get '/dashboard'
      assert_select 'a', I18n.t('dashboard._wiki.more') + Sanitize.clean(' &raquo;')
    end
  end

  test 'should choose i18n for user/_form + user/new' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!
      get '/signup'
      assert_select 'label', I18n.t('users._form.username')
      assert_select 'h2', I18n.t('users.new.sign_up')
    end
  end

  test 'should choose i18n for user/_photo + user/edit' do
    available_testing_locales.each do |lang|
      get '/home'
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      get '/profile/edit'
      assert_select 'h3', I18n.t('users._photo.profile_photo')
      assert_select 'h2', I18n.t('users.edit.edit_profile')
    end
  end

  test 'should choose i18n for user/likes' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      username = users(:jeff).username.to_s
      get '/profile/' + username + '/likes'
      assert_template 'users/likes'
      assert_select 'h3', I18n.t('users.likes.liked_by') + ' ' + username
    end
  end

  test 'should choose i18n for user/list' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/people'
      assert_select 'th', I18n.t('users.list.username')
    end
  end

  test 'should choose i18n for user/map' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/users/map'
      assert_select 'label[for=search]', I18n.t('users.map.search')
    end
  end

  test 'should choose i18n for user/profile' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      get '/profile/' + users(:jeff).username
      assert_select 'h4', I18n.t('users.profile.wiki_contributed_to')
    end
  end

  test 'should choose i18n for user/reset' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      get '/reset'

      assert_response :success
      assert_select 'h2', I18n.t('users.reset.reset_password')
    end
  end

  test 'should choose i18n for user_sessions/new' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/login'
      assert_select 'a[href=?]', '/signup', I18n.t('user_sessions.new.sign_up')
    end
  end

  test 'should choose i18n for wiki/_wiki + wiki/index' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      get '/wiki'
      assert_select 'th', I18n.t('wiki._wikis.likes')
      assert_select 'small', I18n.t('wiki.index.collaborative_documentation')
    end
  end

  test 'should choose i18n for wiki/edit' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      wiki = nodes(:about)
      get '/wiki/edit/' + wiki.title.parameterize
    end
  end

  test 'should choose i18n for wiki/revisions' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/wiki/revisions/' + nodes(:organizers).title.parameterize
      assert_select 'a', I18n.t('wiki.revisions.view')
    end
  end

  test 'should choose i18n for wiki/show' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/wiki/' + nodes(:organizers).title.parameterize
      assert_select 'span', I18n.t('wiki.show.view')
    end
  end

  test 'should choose i18n for sidebar/_author + sidebar/_post_button' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      get '/notes/author/' + users(:jeff).username
      assert_select 'h4', ActionView::Base.full_sanitizer.sanitize(I18n.t('sidebar._author.recent_tags_for_author', url1: '/people/' + users(:jeff).username, author: users(:jeff).username))
      assert_select 'a', I18n.t('sidebar._post_button.write_research_note')
    end
  end

  test 'should choose i18n for sidebar/_related' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/wiki/' + nodes(:organizers).title.parameterize
      assert_select 'a', "#{I18n.t('sidebar._related.write_research_note')} " + Sanitize.clean('&raquo;')
    end
  end

  test 'should choose i18n for comments' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
         params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
         }
      follow_redirect!

      get nodes(:one).path
      assert_select 'a', I18n.t('comments._form.upload_image')
    end
  end

  test 'should choose i18n for tag/blog' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/blog'
      assert_select 'p', I18n.t('tag.blog.stories_from_community')
    end
  end

  test 'should choose i18n for tag/index' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/tags'
      assert_select 'p', I18n.t('tag.index.browse_popular_tags')
    end
  end

  test 'should choose i18n for tag/show' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/tag/some-tag'
      assert_select 'a', I18n.t('tag.show.maps')
    end
  end

  test 'should choose i18n for tag/widget' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/widget/some-tag'
      assert_select 'p', ActionView::Base.full_sanitizer.sanitize(I18n.t('tag.show.no_results_found', tag: 'some-tag')) + ':'
    end
  end

  test 'should choose i18n for talk/show' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/talk/' + nodes(:about).slug
      assert_select 'p', ActionView::Base.full_sanitizer.sanitize(I18n.t('talk.show.welcome', page: nodes(:about).latest.title, url1: nodes(:about).path, url2: '/wiki/talk-pages') + ' | for help, <a href="/chat">visit our chatroom</a>')
    end
  end

  test 'should choose i18n for notes/_comment' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      get nodes(:one).path
      assert_select 'span', I18n.t('notes._comment.commented')
    end
  end

  test 'should choose i18n for notes/_comments' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get nodes(:one).path
      assert_select 'p', ActionView::Base.full_sanitizer.sanitize(I18n.t('notes._comments.must_be_logged_in', url1: '/login'))
    end
  end

  test 'should choose i18n for notes/index' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/notes/popular'
      assert_select 'h2', I18n.t('notes.index.popular_research_notes')
    end
  end

  test 'should choose i18n for notes/show' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      post '/user_sessions',
        params: {
          user_session: {
            username: users(:jeff).username,
            password: 'secretive'
          }
        }
      follow_redirect!

      get nodes(:first_timer_note).path
      assert_template 'notes/show'
      assert_select 'div[class=?]', 'alert alert-warning', ActionView::Base.full_sanitizer.sanitize(I18n.t('notes.show.note_no_tags'))
    end
  end

  test 'should choose i18n for notes/stats' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/stats'
      assert_select 'h2', I18n.t('notes.stats.contributors_statistics')
    end
  end

  test 'should choose i18n for notes/tools_places' do
    available_testing_locales.each do |lang|
      get '/change_locale/' + lang.to_s
      follow_redirect!

      get '/methods'
      assert_select 'h1', ActionView::Base.full_sanitizer.sanitize(I18n.t('notes.tools_places.tools_and_techniques'))
    end
  end
end
