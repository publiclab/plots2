class AddIndexToImagesAndLikes < ActiveRecord::Migration[5.2]
  def change
  	add_index "images", ["nid", "uid"], :name => "index_images_on_nid_uid"
  	add_index "likes", ["likeable_id", "user_id"], :name => "index_likes_on_likeable_id_user_id"
  end
end
