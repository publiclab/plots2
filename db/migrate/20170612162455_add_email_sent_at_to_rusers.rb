class AddEmailSentAtToRusers < ActiveRecord::Migration
  def change
    add_column :rusers, :email_sent_at, :datetime
  end
end
