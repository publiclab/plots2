require 'test_helper'

class I18nTest < ActionDispatch::IntegrationTest
    test "should choose i18n-locale for header partial" do
        available_testing_locales.each do |lang|
            get '/home/?locale='+lang.to_s
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
end


