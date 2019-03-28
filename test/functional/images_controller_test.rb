require 'test_helper'

class ImagesControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
  end

  test "image shortlinks redirect properly" do
    get :shortlink, params: { id: Image.last.id }
    assert_redirected_to Image.last.path(:large)
    get :shortlink, params: { id: Image.last.id, size: 'medium' }
    assert_redirected_to Image.last.path(:medium)
    get :shortlink, params: { id: Image.last.id, size: 'm' }
    assert_redirected_to Image.last.path(:medium)
    get :shortlink, params: { id: Image.last.id, size: 'thumbnail' }
    assert_redirected_to Image.last.path(:thumb)
    get :shortlink, params: { id: Image.last.id, s: 'thumbnail' }
    assert_redirected_to Image.last.path(:thumb)
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
