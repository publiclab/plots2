require 'test_helper'


class SignUpTest < ActionDispatch::IntegrationTest
  def setup
    @new_user = {
      :username => "newuser",
      :email => "newuser@gmail.com",
      :password => "validpassword"
    }
   @spamaway = { statement1: I18n.t('spamaway.human.statement1'),
                 statement2: I18n.t('spamaway.human.statement1'),
                 statement3: I18n.t('spamaway.human.statement1'),
                 statement4: I18n.t('spamaway.human.statement1') }
  end

  test 'display username minimum length error messages' do
    post '/register', params: {
      user: {
        username: 'a',
        email: @new_user[:email],
        password: @new_user[:password],
        password_confirmation: @new_user[:password],
      },
      spamaway: @spamaway
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
      spamaway: @spamaway
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
      spamaway: @spamaway
    }

    assert response.body.include? '2 errors prohibited this user from being saved'
    assert response.body.include? `Username can only consist of alphabets, numbers, underscore '_', and hyphen '-'.`
    assert response.body.include? 'Username is too short (minimum is 3 characters)'
  end

  test 'email error messages' do
    post '/register', params: {
      user: {
        username: 'newuser',
        email: 'notanemail',
        password: 'validpassword',
        password_confirmation: 'valid:password',
      },
      spamaway: @spamaway
    }

    assert response.body.include? 'errors prohibited this user from being saved'
    assert response.body.include? 'Email should look like an email address.'
  end
  
  test 'incomplete spamaway test does not create new user record, returns useful validation' do
    assert_difference 'User.count', 0 do
      post '/register', params: {
        user: {
           username: "newuser",
           email: @new_user[:email],
           password: @new_user[:password],
           password_confirmation: @new_user[:password]
        },
        spamaway: {
          follow_instructions: ""
         }
       } 
    end
    assert response.body.include? '1 error prohibited this user from being saved'
    assert response.body.include? "It doesn&#39;t seem like you are a real person! If you disagree or are having trouble, please see https://publiclab.org/registration-test."
  end
  
  test 'spamaway text area not blank error message' do
    post '/register', params: {
      user: {
         username: "newuser",
         email: @new_user[:email],
         password: @new_user[:password],
         password_confirmation: @new_user[:password]
      },
      spamaway: {
        statement1: @spamaway[:statement1],
        statement2: @spamaway[:statement2],
        statement3: @spamaway[:statement3],
        statement4: @spamaway[:statement4],
        follow_instructions: "Not_Blank"
       }
     } 
    assert response.body.include? '1 error prohibited this user from being saved'
    assert response.body.include? 'Spam detection Please read the instructions in the last box carefully.'
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
        spamaway: @spamaway
      }

      assert response.body.include? '1 error prohibited this user from being saved'
      assert response.body.include? `Username can only consist of alphabets, numbers, underscore '_', and hyphen '-'.`
    end
end
