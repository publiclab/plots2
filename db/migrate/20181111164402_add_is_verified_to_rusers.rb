class AddIsVerifiedToRusers < ActiveRecord::Migration[5.2]
  def change
    add_column :rusers, :is_verified, :boolean ,:default => false
  end
end
