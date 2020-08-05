require 'test_helper'

class BatchControllerTest < ActionController::TestCase

    def setup
        activate_authlogic
        Timecop.freeze
    end
    
    def teardown
        UserSession.find.destroy if UserSession.find
        Timecop.return
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
end
