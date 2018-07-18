class AddPasswordChecker < ActiveRecord::Migration[5.2]
  def change
    add_column :password_checker, :string
  end
end
