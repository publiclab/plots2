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
    # batch spam 
    test 'User which are batch spammed are ban' do
        UserSession.create(users(:moderator))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
        get :batch_spam, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to "/spam2"
        #  check if authors are banned
        authors = spam_nodes.collect { |node| User.find(node.author.id) }
        assert authors.all? { |spammer| spammer.status == 0 }
    end
    
    test "batched spammed notes are spammed and not present in spam2/wiki as a potential spam" do
        UserSession.create(users(:admin))
        spam_node = nodes(:about) 
        get :_spam, params: { type: "wiki" }
        # node should be present on spam suggestions because it is not yet spammed
        assert_select "#n#{spam_node.nid}", 1
        get :batch_spam, params: { ids: spam_node.nid }
        # node is no longer on /spam/wiki because it is now already spammed
        assert_select "#n#{spam_node.nid}", 0
        # call the node from database to check if spammed
        assert_equal 0, Node.find(spam_node.id).status
    end
    
    test 'batch spam ban correct number of users and spam correct number of notes' do
        UserSession.create(users(:admin))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
        authors = spam_nodes.collect { |node| node.author }
        get :batch_spam, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to "/spam2"
        assert_equal spam_nodes.length.to_s + ' nodes spammed and ' + authors.uniq.length.to_s + ' users banned.', flash[:notice]
    end
      
    test 'normal user should not be allowed to batch spam' do
        UserSession.create(users(:bob))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
        get :batch_spam, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_equal "Only admins and moderators can mark a batch spam.", flash[:error]
        assert_redirected_to "/dashboard"
    end
    # batch_publish
    test 'User which are batch Publish are unbaned' do
        UserSession.create(users(:moderator))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
        get :batch_publish, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to "/spam2"
        # check if users are unbanned
        authors = spam_nodes.collect { |node| User.find(node.author.id) }
        assert authors.all? { |spammer| spammer.status == 1 }
    end

    test "batch published notes are published and not present in spam2 as unmoderated note" do
        UserSession.create(users(:admin))
        spam_node = nodes(:spam)
        get :_spam
        # node is spammeed and now present in the /spam2 
        assert_select "#n#{spam_node.nid}", 1
        get :batch_publish, params: { ids: spam_node.nid }
        # node is no longer present as it is published
        assert_select "#n#{spam_node.nid}", 0
        # call the node from database to check if published
        assert_equal 1, Node.find(spam_node.id).status
    end

    test 'batch Publish unban correct number of users and publish correct number of notes' do
        UserSession.create(users(:admin))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
        authors = spam_nodes.collect { |node| node.author }
        get :batch_publish, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        #redirect to same path
        assert_redirected_to '/spam2'
        assert_equal spam_nodes.length.to_s + ' nodes published and ' + authors.uniq.length.to_s + ' users unbanned.', flash[:notice]
    end

    test 'normal user should not be allowed to batch publish' do
        UserSession.create(users(:bob))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
        get :batch_publish, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_equal "Only admins and moderators can batch publish.", flash[:error]
        assert_redirected_to "/dashboard"
    end
    # batch ban 
    test 'User which are batch banned are ban' do
        UserSession.create(users(:moderator))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
        get :batch_ban, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to root_path
        # check if they are banned
        authors = spam_nodes.collect { |node| User.find(node.author.id) }
        assert authors.all? { |spammer| spammer.status == 0 }
    end

    test 'batch ban, ban correct number of users' do
        UserSession.create(users(:admin))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
        authors = spam_nodes.collect { |node| node.author }
        get :batch_ban, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to root_path
        assert_equal authors.uniq.length.to_s + ' users banned.', flash[:notice]
    end
      
    test 'normal user should not be allowed to batch ban' do
        UserSession.create(users(:bob))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
        authors = spam_nodes.collect { |node| node.author }
        get :batch_ban, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",")}
        assert_equal "Only admins and moderators can ban users.", flash[:error]
        assert_redirected_to "/dashboard"
    end
    # batch unban 
    test 'User which are batch unbanned are unban' do
        UserSession.create(users(:moderator))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
        get :batch_unban, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to root_path
        # check if they are unbanned
        authors = spam_nodes.collect { |node| User.find(node.author.id) }
        assert authors.all? { |spammer| spammer.status == 1 }
    end

    test 'batch unban, unban correct number of users' do
        UserSession.create(users(:admin))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
        authors = spam_nodes.collect { |node| node.author }
        get :batch_unban, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to root_path
        assert_equal authors.uniq.length.to_s + ' users unbanned.', flash[:notice]
    end
      
    test 'normal user should not be allowed to batch unban' do
        UserSession.create(users(:bob))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
        authors = spam_nodes.collect { |node| node.author }
        get :batch_unban, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",")}
        assert_equal "Only admins and moderators can unban users.", flash[:error]
        assert_redirected_to "/dashboard"
    end
    #batch delete
    test 'Notes which are batch deleted are deleted' do
        UserSession.create(users(:moderator))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:question)]
        get :batch_delete, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_redirected_to root_path
        # It checks that notes are deleted and number is correct
        assert_equal spam_nodes.length.to_s + ' nodes deleted', flash[:notice]
    end 
    
    test 'normal user should not be allowed to batch delete' do
        UserSession.create(users(:bob))
        spam_nodes = [nodes(:spam_targeted_page), nodes(:spam)]
        get :batch_delete, params: { ids: spam_nodes.collect { |node| node["nid"] }.join(",") }
        assert_equal "Only admins and moderators can batch delete.", flash[:error]
        assert_redirected_to "/dashboard"
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
