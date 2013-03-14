class AddOpenidIdentifierToUsers < ActiveRecord::Migration
  def change
    add_column :rusers, :openid_identifier, :string
  end
end
