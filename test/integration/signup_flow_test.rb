require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  test 'all error messages display on signup' do
    post '/register', params: { 
      user: {
        username: '', 
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
    
    assert response.body.include? 'Email is invalid'
    assert response.body.include? 'Username is too short'
    assert response.body.include? 'Password is too short'
  end

  test 'no redundant email error messages' do
    post '/register', params: { 
      user: {
        username: '', 
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

    assert !(response.body.include? 'Email is invalid')
    assert response.body.include? 'Email should look like an email address.'
  end

end
