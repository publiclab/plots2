class RemovePasswordCheckerFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :password_checker, :integer
  end
end
