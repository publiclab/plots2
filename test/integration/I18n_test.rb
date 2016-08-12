require 'test_helper'

class I18nTest < ActionDispatch::IntegrationTest
    
    test "should choose i18n-locale for footer partial" do
        available_testing_locales.each do |lang|
            get '/home'
            get_via_redirect "/change_locale/"+lang.to_s
            assert_select "a[href=/wiki/issues]", I18n.t("layout._footer.getting_help.report_bug")
        end
    end
    
    test "should choose i18n-locale for header partial" do
        available_testing_locales.each do |lang|
            get '/home'
            get_via_redirect "/change_locale/"+lang.to_s
            assert_select "p[class=facebook-summary]", I18n.t('layout._header.summary')
            post '/user_sessions', user_session: {
              username: rusers(:jeff).username,
              password: 'secret'
            }
            follow_redirect!
            get_via_redirect "/dashboard", :locale => lang
            assert_select "a[href=/dashboard]", I18n.t('layout._header.dashboard')
        end
    end
    
    test "should get change_locale path and set locale" do
        available_testing_locales.each do |lang|
            get "/change_locale/"+lang.to_s
            follow_redirect!
            assert_equal "#{lang}", "#{I18n.locale}"
            get_via_redirect "/dashboard"
            assert_equal "#{lang}", "#{I18n.locale}"
        end
    end
    
    test "should set default_locale for an unavailable locale" do 
        get "/change_locale/"+"unavail_locale".to_s
        follow_redirect!
        assert_equal "#{I18n.locale}", "#{I18n.default_locale}"
    end
    
    test "should choose i18n for subscriptions" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        get '/subscriptions'
        assert_select 'b', I18n.t('home.subscriptions.title')
      end
    end
    
    test "should choose i18n for dashboard/_activity" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        assert_select 'h3', I18n.t('dashboard._activity.activity')
      end
    end
    
    test "should choose i18n for dashboard/_header" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        assert_select 'h1', I18n.t('dashboard._header.dashboard')
      end
    end
    
    test "should choose i18n for dashboard/_node_comment" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        get '/dashboard'
        assert_select 'span', I18n.t('dashboard._node_comment.commented_on')
      end
    end
    
    test "should choose i18n for dashboard/_node_moderate" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        post '/create', 
         title: 'Some post', 
         body: "Some post body", 
         tags: "Some-tag",
         status: 4
        get '/dashboard'
        assert_select 'a[class=btn btn-default btn-xs]', I18n.t('dashboard._node_moderate.approve')
      end
    end
    
    test "should choose i18n for dashboard/_node_question" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        post '/create', 
         title: 'Some question',
         tags: "question",
         status: 1
        get '/dashboard'
        assert_select 'a[class=btn btn-default btn-xs pull-right respond answer]', I18n.t('dashboard._node_question.post_answer')
      end
    end
    
    test "should choose i18n for dashboard/_node_wiki" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        post '/create', 
         title: 'Some topic',
         tags: "some-tag",
         type: 'page',
         status: 1
        get '/dashboard'
        assert_select 'span', I18n.t('dashboard._node_wiki.new_page_by')
      end
    end
    
    test "should choose i18n for dashboard/_sidebar" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        get '/dashboard'
        assert_select 'span', I18n.t('dashboard._sidebar.wiki')
      end
    end
    
    test "should choose i18n for dashboard/_wiki" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        get '/dashboard'
        assert_select 'a', I18n.t('dashboard._wiki.more') + " &raquo;"
      end
    end
    
    test "should choose i18n for user/_form + user/new" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        get '/signup'
        assert_select 'label', I18n.t('users._form.username')
        assert_select 'h2', I18n.t('users.new.sign_up')
      end
    end
    
    test "should choose i18n for user/_photo + user/edit" do
      available_testing_locales.each do |lang|
        get '/home'
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        get '/profile/edit'
        assert_select 'h3', I18n.t('users._photo.profile_photo')
        assert_select 'h2', I18n.t('users.edit.edit_profile')
      end
    end
    
    test "should choose i18n for user/_tags_form + user/info" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        get '/profile/info/'+rusers(:jeff).username.to_s
        assert_select 'label[for=skills]', I18n.t('users._tags_form.skills')
        assert_select 'h2', I18n.t('users.info.additonal_information')
      end
    end
    
    test "should choose i18n for user/likes" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        username = rusers(:jeff).username.to_s
        get '/profile/'+username+'/likes'
        assert_template 'users/likes'
        assert_select 'h3', I18n.t('users.likes.liked_by')+' '+username
      end
    end
    
    test "should choose i18n for user/list" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        get '/people'
        assert_select 'th', I18n.t('users.list.username')
      end
    end
    
    test "should choose i18n for user/map" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        get '/users/map'
        assert_select 'label[for=search]', I18n.t('users.map.search')
      end
    end
    
    test "should choose i18n for user/profile" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        get '/profile/'+rusers(:jeff).username
        assert_select 'h4', I18n.t('users.profile.wiki_contributed_to')
      end
    end
    
    test "should choose i18n for user/reset" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        get '/reset'
        assert_select 'h2', I18n.t('users.reset.reset_password')
      end
    end
    
    test "should choose i18n for user_sessions/new" do
      available_testing_locales.each do |lang|
        get '/login'
        assert_select 'a[href=/signup]', I18n.t('user_sessions.new.sign_up')
      end
    end
    
    test "should choose i18n for wiki/_wiki + wiki/index" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        get '/wiki'
        assert_select 'th', I18n.t('wiki._wikis.likes')
        assert_select 'small', I18n.t('wiki.index.collaborative_documentation')
      end
    end
    
    test "should choose i18n for wiki/edit" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        wiki = node(:about)
        get '/wiki/edit/' + wiki.title.parameterize
        assert_select 'a', I18n.t('wiki.edit.getting_started')
      end
    end
    
    test "should choose i18n for wiki/revisions" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        get '/wiki/revisions/'+node(:organizers).title.parameterize
        assert_select 'a', I18n.t('wiki.revisions.view')
      end
    end
    
    test "should choose i18n for wiki/show" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        get '/wiki/'+node(:organizers).title.parameterize
        assert_select 'span', I18n.t('wiki.show.view')
      end
    end
    
    test "should choose i18n for sidebar/_author + sidebar/_post_button" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        post '/user_sessions', user_session: {
          username: rusers(:jeff).username,
          password: 'secret'
        }
        follow_redirect!
        
        get '/notes/author/'+rusers(:jeff).username
        assert_select 'h4', ActionView::Base.full_sanitizer.sanitize(I18n.t('sidebar._author.recent_tags_for_author', :url1 => "/people/"+rusers(:jeff).username, :author => rusers(:jeff).username))
        assert_select 'a', I18n.t('sidebar._post_button.write_research_note')
      end
    end
    
    test "should choose i18n for sidebar/_related" do
      available_testing_locales.each do |lang|
        get "/change_locale/"+lang.to_s
        follow_redirect!
        
        get '/wiki/'+node(:organizers).title.parameterize
        assert_select 'a', I18n.t('sidebar._related.write_research_note')
      end
    end
end