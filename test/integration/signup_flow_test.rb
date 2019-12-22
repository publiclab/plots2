require 'test_helper'


class SignUpTest < ActionDispatch::IntegrationTest
  def setup
    @new_user = {
      :username => "newuser",
      :email => "newuser@gmail.com",
      :password => "validpassword"
    }
  end

  test 'display username minimum length error messages' do
    post '/register', params: { 
      user: {
        username: 'a', 
        email: @new_user[:email],
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
    
    assert response.body.include? '1 error prohibited this user from being saved'
    assert response.body.include? 'Username is too short (minimum is 3 characters)'
  end

  test 'display username maximum length error messages' do
    post '/register', params: { 
      user: {
        username: 'a' * 101, 
        email: @new_user[:email],
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
    
    assert response.body.include? '1 error prohibited this user from being saved'
    assert response.body.include? 'Username is too long (maximum is 100 characters)'
  end

  test 'display username special characters error messages' do
    test_username_regex 'asdf^'
    test_username_regex 'asdf>'
    test_username_regex 'asdf.'
    test_username_regex 'asdf,'
  end


  test 'display username character and length error messages' do
    post '/register', params: { 
      user: {
        username: '^', 
        email: @new_user[:email],
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
    assert response.body.include? 'Username should use only lowercase letters numbers and _ and should start with a letter.'
    assert response.body.include? 'Username is too short (minimum is 3 characters)'
  end

  private
    
    def test_username_regex(name)
      post '/register', params: { 
        user: {
          username: name, 
          email: @new_user[:email],
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
      
      assert response.body.include? '1 error prohibited this user from being saved'
      assert response.body.include? 'Username should use only letters, numbers, spaces, and .-_@+ please.'
    end
end
