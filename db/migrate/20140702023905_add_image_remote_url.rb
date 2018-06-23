class AddImageRemoteUrl < ActiveRecord::Migration[5.1]
  def up
    add_column :images, :remote_url, :string
  end

  def down
    remove_column :images, :remote_url, :string
  end
end
