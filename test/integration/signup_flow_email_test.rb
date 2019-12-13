require 'test_helper'


class SignUpTest < ActionDispatch::IntegrationTest
  def setup
    @new_user = {
      :username => "newuser",
      :email => "newuser@gmail.com",
      :password => "validpassword"
    }
  end

  test 'email error messages' do
    post '/register', params: { 
      user: {
        username: @new_user[:username], 
        email: 'notanemail',
        password: @new_user[:password],
        password_confirmation: @new_user[:password],
      },
      spamaway: {
        statement1: I18n.t('spamaway.human.statement1'),
        statement2: I18n.t('spamaway.human.statement1'),
        statement3: I18n.t('spamaway.human.statement1'),
        statement4: I18n.t('spamaway.human.statement1')
      }
    }

    assert response.body.include? '2 errors prohibited this user from being saved'
    assert response.body.include? 'Email should look like an email address.'
  end
end
