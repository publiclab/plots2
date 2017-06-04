class AddEmailSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_sent_at, :datetime
  end
end
