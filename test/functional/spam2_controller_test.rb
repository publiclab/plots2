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
    #Users moderation access control
    test 'Normal users should not be able to access the spam2/users page' do
        UserSession.create(users(:bob))
        get :_spam_users
        assert_equal 'Only moderators can moderate other users.', flash[:error]
        assert_redirected_to '/dashboard'
    end
    
    test 'Moderators should be able to access the spam2/users page' do
        UserSession.create(users(:moderator))
        get :_spam_users
        assert_response :success
        assert_not_nil assigns(:users)
    end
    
    test 'Admins should be able to access the spam2/users page' do
        UserSession.create(users(:admin))
        get :_spam_users
        assert_response :success
        assert_not_nil assigns(:users)
    end
    #Insight section in spam2 access control
    test 'Normal users should not be able to access the spam2/insights page' do
        UserSession.create(users(:bob))
        get :_spam_insights
        assert_equal 'Only moderators and admins can access this page.', flash[:error]
        assert_redirected_to '/dashboard'
    end
    
    test 'Moderators should be able to access the spam2/insights page' do
        UserSession.create(users(:moderator))
        get :_spam_insights
        assert_response :success
        assert_not_nil assigns(:graph_spammed)
    end
    
    test 'Admins should be able to access the spam2/insights page' do
        UserSession.create(users(:admin))
        get :_spam_insights
        assert_response :success
        assert_not_nil assigns(:graph_spammed)
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
    #insights and graphs
    test '_spam_insights should assign correct value to graph_spammed' do
        UserSession.create(users(:moderator))
        Node.delete_all
        node1 = Node.new(uid: users(:bob).id,
        type: 'note',
        title: 'node1',
        status: 0)
        get :_spam_insights
        assert_equal assigns(:graph_spammed), Node.spam_graph_making(0)
        assert_response :success
      end

    test '_spam_insights should assign correct value to graph_unmoderated' do
        UserSession.create(users(:moderator))
        Node.delete_all
        node2 = Node.new(uid: users(:bob).id,
        type: 'note',
        title: 'node2',
        status: 4)       
        get :_spam_insights
        assert_equal assigns(:graph_unmoderated), Node.spam_graph_making(4)
        assert_response :success
    end
    
    test '_spam_insights should assign correct value to graph_flagged' do
        UserSession.create(users(:moderator))
        Node.delete_all
        node3 = Node.new(uid: users(:bob).id,
        type: 'note',
        title: 'node3',
        status: 1,
        flag: 1)
        get :_spam_insights
        assert_equal assigns(:graph_flagged), Node.spam_graph_making(1)
        assert_response :success
    end
end
