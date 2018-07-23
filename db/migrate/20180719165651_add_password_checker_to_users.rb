class AddPasswordCheckerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_checker, :integer, default: 0
  end
end
