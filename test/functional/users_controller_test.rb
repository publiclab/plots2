require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    User.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    User.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to root_url
  end

  def test_edit
    get :edit, :id => User.first
    assert_template 'edit'
  end

  def test_update_invalid
    User.any_instance.stubs(:valid?).returns(false)
    put :update, :id => User.first
    assert_template 'edit'
  end

  def test_update_valid
    User.any_instance.stubs(:valid?).returns(true)
    put :update, :id => User.first
    assert_redirected_to root_url
  end
end
