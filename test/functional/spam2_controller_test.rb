require 'test_helper'

class Spam2ControllerTest < ActionController::TestCase

    def setup
        activate_authlogic
        Timecop.freeze
    end
    
    def teardown
        UserSession.find.destroy if UserSession.find
        Timecop.return
    end
    # spam2 page access control
    test 'Normal users should not be able to see spam2 page' do
        UserSession.create(users(:bob))
        get :_spam
        assert_equal 'Only moderators can moderate posts.', flash[:error]
        assert_redirected_to '/dashboard'
    end

    test 'Moderators should be able to access the spam2 page' do
        UserSession.create(users(:moderator))
        get :_spam
        assert_response :success
        assert_not_nil assigns(:nodes)
     end
    
    test 'Admins should be able to access spam2 page' do
        UserSession.create(users(:admin))
        get :_spam
        assert_response :success
        assert_not_nil assigns(:nodes)
    end
    # Revision Page access control
    test 'Normal users should not be able to access the spam2/revision page' do
        UserSession.create(users(:bob))
        get :_spam_revisions
        assert_equal 'Only moderators and admins can moderate this.', flash[:error]
        assert_redirected_to '/dashboard'
    end
    
    test 'Moderators should be able to access the spam2/revision page' do
        UserSession.create(users(:moderator))
        get :_spam_revisions
        assert_response :success
        assert_not_nil assigns(:revisions)
    end
    
    test 'Admins should be able to access the spam2/revision page' do
        UserSession.create(users(:admin))
        get :_spam_revisions
        assert_response :success
        assert_not_nil assigns(:revisions)
    end
    # Comments access control
    test 'Normal users should not be able to access the spam2/comments page' do
        UserSession.create(users(:bob))
        get :_spam_comments
        assert_equal 'Only moderators can moderate comments.', flash[:error]
        assert_redirected_to '/dashboard'
    end
    
    test 'Moderators should be able to access the spam2/comments page' do
        UserSession.create(users(:moderator))
        get :_spam_comments
        assert_response :success
        assert_not_nil assigns(:comments)
    end
    
    test 'Admins should be able to access the spam2/comments page' do
        UserSession.create(users(:admin))
        get :_spam_comments
        assert_response :success
        assert_not_nil assigns(:comments)
    end
    # Flags access control
    test 'Normal users should not be able to access the spam2/flags page' do
        UserSession.create(users(:bob))
        get :_spam_flags
        assert_equal 'Only moderators can moderate posts.', flash[:error]
        assert_redirected_to '/dashboard'
    end
    
    test 'Moderators should be able to access the spam2/flags page' do
        UserSession.create(users(:moderator))
        get :_spam_flags
        assert_response :success
        assert_not_nil assigns(:flags)
    end
    
    test 'Admins should be able to access the spam2/flags page' do
        UserSession.create(users(:admin))
        get :_spam_flags
        assert_response :success
        assert_not_nil assigns(:flags)
    end
    #flag Nodes
    test 'Anyone should be able to flag a node' do
        UserSession.create(users(:bob))
        node = nodes(:spam)
        post :flag_node, params: { id: node.id }
        node = assigns(:node)
        assert_equal 1, node.flag
        assert_equal 'Node flagged.', flash[:notice]
    end    
    #unflag nodes
    test 'Normal user should not be able to unflag a node' do
        UserSession.create(users(:bob))
        node = nodes(:about)
        post :remove_flag_node, params: { id: node.id }
        assert_equal 'Only admins and moderators can unflag nodes.', flash[:error]
        assert_redirected_to '/dashboard'
    end

    test 'Moderator should be able to unflag a node' do
        UserSession.create(users(:moderator))
        node = nodes(:about)
        post :remove_flag_node, params: { id: node.id }
        node = assigns(:node)
        assert_equal 0, node.flag
    end
      
    test 'Admins should be able to unflag a node' do
        UserSession.create(users(:admin))
        node = nodes(:about)
        post :remove_flag_node, params: { id: node.id }
        node = assigns(:node)
        assert_equal 0, node.flag
    end
    #flag Comments
    test 'Anyone should be able to flag a comment' do
        UserSession.create(users(:bob))
        comment = comments(:first)
        post :flag_comment, params: { id: comment.id }
        assert_equal 'Comment flagged.', flash[:notice]
        comment = assigns(:comment)
        assert_equal 1, comment.flag
    end
    #unflag comments
    test 'Normal user should not be able to unflag a comment' do
        UserSession.create(users(:bob))
        comment = comments(:second)
        post :remove_flag_comment, params: { id: comment.id }
        assert_equal 'Only moderators can unflag comments.', flash[:error]
        assert_redirected_to '/dashboard'
    end

    test 'Moderator should be able to unflag a comment' do
        UserSession.create(users(:moderator))
        comment = comments(:second)
        post :remove_flag_comment, params: { id: comment.id }
        comment = assigns(:comment)
        assert_equal 0, comments(:second).flag
    end
      
    test 'Admins should be able to unflag a comment' do
        UserSession.create(users(:admin))
        comment = comments(:second)
        post :remove_flag_comment, params: { id: comment.id }
        comment = assigns(:comment)
        assert_equal 0, comments(:second).flag
    end
end
