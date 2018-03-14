class AddOmniauthToRusers < ActiveRecord::Migration
  def change
    add_column :rusers, :provider, :string
    add_column :rusers, :uid, :string
  end
end
