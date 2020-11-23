# def show
# def liked? params[:id]
# def create
# def delete
# def set_liking(value)

require 'test_helper'

class LikeControllerTest < ActionController::TestCase
  def setup
    activate_authlogic
  end

  def teardown; end

  test 'show like' do
    note = Node.where(type: 'note', status: 1).first
    get :show, params: { id: note.id }
    assert_response :success
  end

  test 'create like' do
    UserSession.create(User.find(2))
    current_user = User.find 2
    note = Node.where(type: 'note', status: 1).first
    cached_likes = note.cached_likes

    get :create, params: { id: note.id }
    assert_response :success

    note = Node.find note.id
    assert_equal @response.body, '1'
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes + 1, note.cached_likes
    assert ActionMailer::Base.deliveries.size, 1
    assert ActionMailer::Base.deliveries.collect(&:to).include?([note.author.email])
    assert ActionMailer::Base.deliveries.collect(&:subject).include?("[PublicLab] " + (note.has_power_tag('question') ? 'Question: ' : '') + "#{note.title} (##{note.id}) ")
  end

  test 'delete like' do
    UserSession.create(User.find(2))
    current_user = User.find 2
    note = Node.where(type: 'note', status: 1).first

    get :create, params: { id: note.id } # ensure it's liked first

    note = Node.find note.id
    cached_likes = note.cached_likes
    get :delete, params: { id: note.id }
    assert_response :success

    note = Node.find note.id
    assert_equal @response.body, '-1'
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes - 1, note.cached_likes
  end

  test 'show recent likes' do
    get :index

    assert_response :success
    assert_template :index
  end

  test 'decrease of like cache count when user is banned' do
    UserSession.create(User.find(2))
    current_user = User.find 2
    note = Node.where(type: 'note', status: 1).first
    cached_likes = note.cached_likes

    get :create, params: { id: note.id } #first liked

    note = Node.find note.id
    cached_likes =  note.cached_likes

    current_user = User.find 2
    current_user.ban    #banned user

    note = Node.find note.id
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes-1 , note.cached_likes
  end

  # cached likes includes moderated users, whereas likers do not
  test 'moderated likes' do
    UserSession.create(User.find(2))
    note = Node.where(type: 'note', status: 1).first

    get :create, params: { id: note.id } #first liked

    note = Node.find note.id

    current_user = User.find 2
    current_user.moderate    #moderated user

    note = Node.find note.id
    assert_equal note.likers.count, note.cached_likes - 1
  end

  # using likers will exclude moderated and banned users on the likes count
  test 'moderated not included' do
    UserSession.create(User.find(2))
    note = Node.where(type: 'note', status: 1).first
    likers_length =  note.likers.count

    get :create, params: { id: note.id } #first liked

    note = Node.find note.id
    assert_equal  likers_length + 1 , note.likers.count
  end

  test 'create like without notifying author if notify-likes-direct:false tag present' do
    UserSession.create(User.find(1))
    current_user = User.find 1
    note = nodes(:activity)
    cached_likes = note.cached_likes

    get :create, params: { id: note.id }
    assert_response :success

    note = Node.find note.id
    assert_equal @response.body, '1'
    assert_equal note.likers.length, note.cached_likes
    assert_equal cached_likes + 1, note.cached_likes
    assert ActionMailer::Base.deliveries.size, 0
    assert_not ActionMailer::Base.deliveries.collect(&:to).include?([note.author.email])
    assert_not ActionMailer::Base.deliveries.collect(&:subject).include?("[PublicLab] #{current_user.username} liked your " + (note.has_power_tag('question') ? 'question' : 'research note'))
  end
end
