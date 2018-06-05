class AddMessageIdColumnToComments < ActiveRecord::Migration
  def change
  	add_column :comments, :message_id, :string, :default => nil
  end
end
