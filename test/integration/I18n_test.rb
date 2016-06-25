require 'test_helper'

class I18nTest < ActionDispatch::IntegrationTest
    
    test "should choose i18n-locale for footer partial" do
        available_testing_locales.each do |lang|
            get '/home'
            get_via_redirect "/change_locale/"+lang.to_s
            assert_select "a[href=/wiki/issues]", I18n.t("layout._footer.getting_help.report_bug")
            assert true
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
            assert true
        end
    end
    
    test "should get change_locale path and set locale" do
        available_testing_locales.each do |lang|
            get "/change_locale/"+lang.to_s
            follow_redirect!
            assert_equal "#{lang}", "#{I18n.locale}"
            get_via_redirect "/dashboard"
            assert_equal "#{lang}", "#{I18n.locale}"
            assert true
        end
    end
    
    test "should set default_locale for an unavailable locale" do 
        get "/change_locale/"+"unavail_locale".to_s
        follow_redirect!
        assert_equal "#{I18n.locale}", "#{I18n.default_locale}"
        assert true
    end
    
end