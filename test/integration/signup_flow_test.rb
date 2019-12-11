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
    assert !(response.body.include? 'Username is too short (minimum is 3 characters)')
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
