require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  # def create
  # def new
  # def update

  def setup
    activate_authlogic
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
end
