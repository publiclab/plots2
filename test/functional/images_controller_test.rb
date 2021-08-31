require 'test_helper'

class ImagesControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "image shortlinks redirect properly" do
    get :shortlink, params: { id: images(:one).id }
    assert_redirected_to images(:one).path(:large)
    get :shortlink, params: { id: images(:one).id, size: 'medium' }
    assert_redirected_to images(:one).path(:medium)
    get :shortlink, params: { id: images(:one).id, size: 'm' }
    assert_redirected_to images(:one).path(:medium)
    get :shortlink, params: { id: images(:one).id, size: 'thumbnail' }
    assert_redirected_to images(:one).path(:thumb)
    get :shortlink, params: { id: images(:one).id, s: 'thumbnail' }
    assert_redirected_to images(:one).path(:thumb)
  end
  
  test "image shortlinks redirect properly with non-images, like PDFs" do
    get :shortlink, params: { id: images(:pdf).id }
    assert_redirected_to images(:pdf).path(:original) # as default size
    get :shortlink, params: { id: images(:pdf).id, s: 'thumbnail' }
    assert_redirected_to images(:pdf).path(:original) # should return original regardless of requested size
  end

  #  test "normal user should not delete image" do
  #    UserSession.new(drupal_users(:bob))
  #    post :delete, id: Image.last.id
  #    assert_equal flash[:error], "Only admins can delete wiki pages."
  #    assert_redirected_to "/wiki/" + title.parameterize # use node_path?
  #  end

  #  test "admin user should delete image" do
  #    UserSession.new(drupal_users(:admin))
  #    post :delete, id: Image.last.id
  #    assert_equal flash[:notice], "Wiki revision deleted."
  #    assert_redirected_to "/wiki/" + title.parameterize # use node_path?

  ## also ensure any revisions/wiki pages/notes using this image have been re-assigned a most-recent, or no image

  #  end
  test 'image creation success should render the details about the image in the form of json' do
    user = UserSession.create(users(:jeff))
    upload_photo = fixture_file_upload('rails.png', 'image/png')
    post :create,
        params: {
            image: {
                photo: upload_photo,
                title: 'Rails image',
            },
        }
    assert_equal 'application/json', @response.content_type
  end

  test 'upload a small gif' do
    user = UserSession.create(users(:jeff))
    upload_photo = fixture_file_upload('small.gif', 'image/gif')
    post :create,
        params: {
            image: {
                photo: upload_photo,
                title: 'Rails image',
            },
        }
    assert_response :success
  end

# We'd like to do this but don't want to have to add a big gif to the repository... 
# We need to synthesize a fake big gif locally? (it won't be processed anyways)
#   test 'rejecting upload of a big gif' do
#     user = UserSession.create(users(:jeff))
#     upload_photo = fixture_file_upload('small.gif', 'image/gif')
#     post :create,
#         params: {
#             image: {
#                 photo: upload_photo,
#                 title: 'Rails image',
#             },
#         }
#     assert_response :failure
#   end

  test 'creation via daturl' do
    user = UserSession.create(users(:jeff))
    data = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAQABADASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAf/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAABgj/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABykX//Z"
    post :create,
        params: {
          data: data
        }
    assert "dataurl.jpeg", Image.last.filename
  end
end
