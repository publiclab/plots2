class AddMessageIdColumnToComments < ActiveRecord::Migration[5.1]
  def change
  	add_column :comments, :message_id, :string, :default => nil
  end
end
