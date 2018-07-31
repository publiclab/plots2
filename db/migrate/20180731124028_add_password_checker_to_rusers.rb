class AddPasswordCheckerToRusers < ActiveRecord::Migration[5.2]
  def change
    add_column :rusers, :password_checker, :integer, default: 0
  end
end
