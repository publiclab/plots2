class AddIsVerifiedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_verified, :boolean, :default => false
  end
end
