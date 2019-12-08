require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  test 'username length error messages' do
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
  end
  
  test 'username character error messages' do
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
    
    assert response.body.include? 'Username should use only letters, numbers, spaces, and .-_@+ please.'
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

  test 'no redundant username error messages' do
    post '/register', params: { 
      user: {
        username: '^', 
        email: '',
        password: '',
        password_confirmation: '',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }

    assert !(response.body.include? 'Username is invalid')
  end

  test 'no redundant email error messages' do
    post '/register', params: { 
      user: {
        username: 'validusername', 
        email: 'notanemail',
        password: '',
        password_confirmation: '',
      },
      spamaway: {
        follow_instructions: '',
        statement1: '',
        statement2: '',
        statement3: '',
        statement4: ''
      }
    }

    assert !(response.body.include? 'Email is invalid')
  end

end
