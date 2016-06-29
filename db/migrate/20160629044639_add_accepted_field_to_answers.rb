class AddAcceptedFieldToAnswers < ActiveRecord::Migration
  def up
  	add_column :answers, :accepted, :boolean, default: false
  end

  def down
  	remove_column :answers, :accepted
  end
end
