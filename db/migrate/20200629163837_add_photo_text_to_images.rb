class AddPhotoTextToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :photo_text, :string
  end
end
