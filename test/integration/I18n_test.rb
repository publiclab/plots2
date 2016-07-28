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
    
    test "should choose i18n-de and move back to i18n-en" do
      post '/user_sessions', user_session: {
        username: rusers(:jeff).username,
        password: 'secret'
      }
      follow_redirect!
      get '/dashboard'
      
      # Set the language as Deutsch
      lang=:de
      get_via_redirect "/change_locale/"+lang.to_s
      assert_equal "#{lang}", "#{I18n.locale}"
      
      # Move back to English(Default locale)
      lang=:en
      get_via_redirect "/change_locale/"+lang.to_s
      assert_equal "#{lang}", "#{I18n.locale}"
    end
end