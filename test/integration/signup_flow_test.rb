require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  test 'username min length error messages' do
    post '/register', params: { 
      user: {
        username: 'a', 
        email: 'validemail@gmail.com',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Username is too short (minimum is 3 characters)'
    assert !(response.body.include? 'Username should use only letters, numbers, spaces, and .-_@+ please.')
  end

  test 'username max length error messages' do
    post '/register', params: { 
      user: {
        username: 'a' * 101, 
        email: 'validemail@gmail.com',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Username is too long (maximum is 100 characters)'
  end

  test 'username character error messages' do
    post '/register', params: { 
      user: {
        username: 'xzd^', 
        email: 'validemail@gmail.com',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Username should use only letters, numbers, spaces, and .-_@+ please.'
  end

  test 'username character and length error messages' do
    post '/register', params: { 
      user: {
        username: '^', 
        email: 'validemail@gmail.com',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Username should use only letters, numbers, spaces, and .-_@+ please.'
    assert response.body.include? 'Username is too short (minimum is 3 characters)'
  end

  test 'password length error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: 'validemail@gmail.com',
        password: 'a',
        password_confirmation: 'a',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Password is too short (minimum is 8 characters)'
  end

  test 'password confirmation error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: 'validemail@gmail.com',
        password: 'aaaaaaaa',
        password_confirmation: 'bbbbbbbb',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Password confirmation doesn&#39;t match Password'
  end

  test 'password confirmation and length error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: 'validemail@gmail.com',
        password: 'a',
        password_confirmation: 'b',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Password confirmation doesn&#39;t match Password'
    assert response.body.include? 'Password confirmation is too short (minimum is 8 characters)'
  end

  test 'email error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: 'notanemail',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Email should look like an email address.'
  end
  
  test 'email max length error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: 'a' * 100 + '@gmail.com',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Email is too long (maximum is 100 characters)'
  end

  test 'recaptcha error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: 'validemail@gmail.com',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }
    
    assert response.body.include? 'Spam detection -- It doesn&#39;t seem like you are a real person! If you disagree or are having trouble, please see https://publiclab.org/registration-test.'
  end

  test 'custom blank email error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: '',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }

    assert response.body.include? 'Email cannot be blank'
  end

  test 'custom blank username error messages' do
    post '/register', params: { 
      user: {
        username: '', 
        email: 'validemail@gmail.com',
        password: 'validpassword',
        password_confirmation: 'validpassword',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }

    assert response.body.include? 'Username cannot be blank'
  end
end
