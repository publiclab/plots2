class AddOpenidIdentifierToUsers < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? "rusers", :openid_identifier
      add_column :rusers, :openid_identifier, :string
    end
  end
end
