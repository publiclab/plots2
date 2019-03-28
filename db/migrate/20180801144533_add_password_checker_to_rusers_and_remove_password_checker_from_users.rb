class AddPasswordCheckerToRusersAndRemovePasswordCheckerFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :password_checker, :integer
    add_column :rusers, :password_checker, :integer, default: 0
  end
end
